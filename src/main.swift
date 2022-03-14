import AltSign
import ArgumentParser
import Foundation

var exitSignal = DispatchSemaphore(value: 0)

struct Noxc: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "A command-line tool to manage free certificates and provisioning profiles",
        subcommands: [Teams.self])

    init() {}
}

struct Teams: ParsableCommand {
    public static let configuration = CommandConfiguration(abstract: "Lists teams associated with account.")

    func run() throws {
        print("fetching teams")
        Task {
            do {
                let (_api, _account, _session) = try await authenticate()
                print("authenticated")
            } catch {
                print(error)
            }
            exitSignal.signal()
        }
    }
}

private extension UserDefaults {
    @objc var localUserID: String? {
        get { return self.string(forKey: #keyPath(UserDefaults.localUserID)) }
        set { self.set(newValue, forKey: #keyPath(UserDefaults.localUserID)) }
    }
}

func authenticate() async throws -> (ALTAppleAPI, ALTAccount, ALTAppleAPISession) {
    let userName = ProcessInfo.processInfo.environment["username"]!
    let password = ProcessInfo.processInfo.environment["password"]!

    dlopen("/System/Library/PrivateFrameworks/AuthKit.framework/AuthKit", RTLD_NOW)

    var request = URLRequest(url: URL(string: "https://developerservices2.apple.com")!)
    request.httpMethod = "POST"
    let akAppleIDSession = unsafeBitCast(NSClassFromString("AKAppleIDSession")!, to: AKAppleIDSession.Type.self)
    let session = akAppleIDSession.init(identifier: "com.apple.gs.xcode.auth")
    let headers = session.appleIDHeaders(for: request)

    let akDevice = unsafeBitCast(NSClassFromString("AKDevice")!, to: AKDevice.Type.self)
    let device = akDevice.current

    var localUserID = UserDefaults.standard.localUserID
    if localUserID == nil {
        localUserID = UUID().uuidString
        UserDefaults.standard.localUserID = localUserID
    }

    let anisetteData = ALTAnisetteData(
        machineID: headers["X-Apple-I-MD-M"] ?? "",
        oneTimePassword: headers["X-Apple-I-MD"] ?? "",
        localUserID: headers["X-Apple-I-MD-LU"] ?? localUserID!,
        routingInfo: UInt64(headers["X-Apple-I-MD-RINFO"] ?? "") ?? 0,
        deviceUniqueIdentifier: device.uniqueDeviceIdentifier,
        deviceSerialNumber: device.serialNumber,
        //deviceDescription: device.serverFriendlyDescription,
        deviceDescription: "<MacBookPro15,1> <Mac OS X;10.15.2;19C57> <com.apple.AuthKit/1 (com.apple.dt.Xcode/3594.4.19)>",
        date: Date(),
        locale: .current,
        timeZone: .current
    )
    print(anisetteData)

    let api = ALTAppleAPI.init()

    print("starting authentication")
    let result: (ALTAccount, ALTAppleAPISession) =
        try await withCheckedThrowingContinuation { continuation in
            api.authenticate(
                appleID: userName,
                password: password,
                anisetteData: anisetteData,
                verificationHandler: nil,
                completionHandler: { (account, session, error) in
                    let result: Result<(ALTAccount, ALTAppleAPISession), Error> =
                        error == nil ? .success((account!, session!))
                        : .failure(error!)
                    continuation.resume(with: result)
                }
            )
        }
    let (account, apisession) = result;
    return (api, account, apisession)
}

Noxc.main()
exitSignal.wait()
