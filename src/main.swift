import ArgumentParser

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
    }
}

Noxc.main()
