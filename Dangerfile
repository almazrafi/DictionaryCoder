def report_xcode_summary(platform:)
    path = "xcodebuild-#{platform.downcase}.json"

    return if !File.exist?(path)

    data = File.read(path)
    json = JSON.parse(data)

    json["tests_summary_messages"].each { |message|
        if !message.empty?
            message.insert(1, " " + platform + ":")
        end
    }

    File.open(path, "w") do |file|
        file.puts JSON.pretty_generate(json)
    end

    xcode_summary.report(path)
end

warn('This pull request is marked as Work in Progress. DO NOT MERGE!') if github.pr_title.include? "[WIP]"

swiftlint.lint_all_files = true
swiftlint.lint_files(fail_on_error: true, inline_mode: true)

report_xcode_summary(platform: "iOS")
report_xcode_summary(platform: "macOS")
report_xcode_summary(platform: "tvOS")
report_xcode_summary(platform: "watchOS")
