//
//  AppTemplate.swift
//  subscription-tracker
//
//  App template for subscription presets
//

import Foundation

/// Predefined app template for quick subscription creation
struct AppTemplate: Identifiable, Hashable {
    let id: String
    let name: String
    let iconURL: String

    /// First letter for alphabetical indexing
    var firstLetter: String {
        String(name.prefix(1).uppercased())
    }
}

/// Predefined app templates
struct AppTemplates {
    static let all: [AppTemplate] = [
        // MARK: - Entertainment / Streaming
        AppTemplate(id: "netflix", name: "Netflix", iconURL: "https://www.google.com/s2/favicons?domain=netflix.com&sz=128"),
        AppTemplate(id: "spotify", name: "Spotify", iconURL: "https://www.google.com/s2/favicons?domain=spotify.com&sz=128"),
        AppTemplate(id: "youtube", name: "YouTube Premium", iconURL: "https://www.google.com/s2/favicons?domain=youtube.com&sz=128"),
        AppTemplate(id: "disney", name: "Disney+", iconURL: "https://www.google.com/s2/favicons?domain=disneyplus.com&sz=128"),
        AppTemplate(id: "hulu", name: "Hulu", iconURL: "https://www.google.com/s2/favicons?domain=hulu.com&sz=128"),
        AppTemplate(id: "max", name: "Max", iconURL: "https://www.google.com/s2/favicons?domain=max.com&sz=128"),
        AppTemplate(id: "prime-video", name: "Amazon Prime Video", iconURL: "https://www.google.com/s2/favicons?domain=primevideo.com&sz=128"),
        AppTemplate(id: "apple-music", name: "Apple Music", iconURL: "https://www.google.com/s2/favicons?domain=music.apple.com&sz=128"),
        AppTemplate(id: "apple-tv", name: "Apple TV+", iconURL: "https://www.google.com/s2/favicons?domain=tv.apple.com&sz=128"),
        AppTemplate(id: "paramount", name: "Paramount+", iconURL: "https://www.google.com/s2/favicons?domain=paramountplus.com&sz=128"),
        AppTemplate(id: "peacock", name: "Peacock", iconURL: "https://www.google.com/s2/favicons?domain=peacocktv.com&sz=128"),
        AppTemplate(id: "crunchyroll", name: "Crunchyroll", iconURL: "https://www.google.com/s2/favicons?domain=crunchyroll.com&sz=128"),
        AppTemplate(id: "tidal", name: "TIDAL", iconURL: "https://www.google.com/s2/favicons?domain=tidal.com&sz=128"),
        AppTemplate(id: "audible", name: "Audible", iconURL: "https://www.google.com/s2/favicons?domain=audible.com&sz=128"),
        AppTemplate(id: "kindle-unlimited", name: "Kindle Unlimited", iconURL: "https://www.google.com/s2/favicons?domain=amazon.com&sz=128"),
        AppTemplate(id: "twitch", name: "Twitch", iconURL: "https://www.google.com/s2/favicons?domain=twitch.tv&sz=128"),
        AppTemplate(id: "deezer", name: "Deezer", iconURL: "https://www.google.com/s2/favicons?domain=deezer.com&sz=128"),
        AppTemplate(id: "soundcloud", name: "SoundCloud Go", iconURL: "https://www.google.com/s2/favicons?domain=soundcloud.com&sz=128"),
        AppTemplate(id: "amazon-music", name: "Amazon Music", iconURL: "https://www.google.com/s2/favicons?domain=music.amazon.com&sz=128"),
        AppTemplate(id: "mubi", name: "MUBI", iconURL: "https://www.google.com/s2/favicons?domain=mubi.com&sz=128"),

        // MARK: - Entertainment (China)
        AppTemplate(id: "bilibili", name: "Bilibili", iconURL: "https://www.google.com/s2/favicons?domain=bilibili.com&sz=128"),
        AppTemplate(id: "iqiyi", name: "iQIYI", iconURL: "https://www.google.com/s2/favicons?domain=iqiyi.com&sz=128"),
        AppTemplate(id: "youku", name: "Youku", iconURL: "https://www.google.com/s2/favicons?domain=youku.com&sz=128"),
        AppTemplate(id: "tencent-video", name: "Tencent Video", iconURL: "https://www.google.com/s2/favicons?domain=v.qq.com&sz=128"),
        AppTemplate(id: "mango-tv", name: "Mango TV", iconURL: "https://www.google.com/s2/favicons?domain=mgtv.com&sz=128"),
        AppTemplate(id: "netease-music", name: "NetEase Music", iconURL: "https://www.google.com/s2/favicons?domain=music.163.com&sz=128"),
        AppTemplate(id: "qq-music", name: "QQ Music", iconURL: "https://www.google.com/s2/favicons?domain=y.qq.com&sz=128"),

        // MARK: - Entertainment (Japan / Korea)
        AppTemplate(id: "line-music", name: "LINE MUSIC", iconURL: "https://www.google.com/s2/favicons?domain=music.line.me&sz=128"),
        AppTemplate(id: "u-next", name: "U-NEXT", iconURL: "https://www.google.com/s2/favicons?domain=unext.jp&sz=128"),

        // MARK: - Productivity & Cloud
        AppTemplate(id: "notion", name: "Notion", iconURL: "https://www.google.com/s2/favicons?domain=notion.so&sz=128"),
        AppTemplate(id: "evernote", name: "Evernote", iconURL: "https://www.google.com/s2/favicons?domain=evernote.com&sz=128"),
        AppTemplate(id: "dropbox", name: "Dropbox", iconURL: "https://www.google.com/s2/favicons?domain=dropbox.com&sz=128"),
        AppTemplate(id: "google-one", name: "Google One", iconURL: "https://www.google.com/s2/favicons?domain=one.google.com&sz=128"),
        AppTemplate(id: "microsoft-365", name: "Microsoft 365", iconURL: "https://www.google.com/s2/favicons?domain=microsoft365.com&sz=128"),
        AppTemplate(id: "icloud", name: "iCloud+", iconURL: "https://www.google.com/s2/favicons?domain=icloud.com&sz=128"),
        AppTemplate(id: "todoist", name: "Todoist", iconURL: "https://www.google.com/s2/favicons?domain=todoist.com&sz=128"),
        AppTemplate(id: "1password", name: "1Password", iconURL: "https://www.google.com/s2/favicons?domain=1password.com&sz=128"),
        AppTemplate(id: "lastpass", name: "LastPass", iconURL: "https://www.google.com/s2/favicons?domain=lastpass.com&sz=128"),
        AppTemplate(id: "grammarly", name: "Grammarly", iconURL: "https://www.google.com/s2/favicons?domain=grammarly.com&sz=128"),
        AppTemplate(id: "dashlane", name: "Dashlane", iconURL: "https://www.google.com/s2/favicons?domain=dashlane.com&sz=128"),
        AppTemplate(id: "bear", name: "Bear", iconURL: "https://www.google.com/s2/favicons?domain=bear.app&sz=128"),
        AppTemplate(id: "craft", name: "Craft", iconURL: "https://www.google.com/s2/favicons?domain=craft.do&sz=128"),
        AppTemplate(id: "things", name: "Things Cloud", iconURL: "https://www.google.com/s2/favicons?domain=culturedcode.com&sz=128"),
        AppTemplate(id: "fantastical", name: "Fantastical", iconURL: "https://www.google.com/s2/favicons?domain=flexibits.com&sz=128"),
        AppTemplate(id: "setapp", name: "Setapp", iconURL: "https://www.google.com/s2/favicons?domain=setapp.com&sz=128"),

        // MARK: - Communication
        AppTemplate(id: "slack", name: "Slack", iconURL: "https://www.google.com/s2/favicons?domain=slack.com&sz=128"),
        AppTemplate(id: "zoom", name: "Zoom", iconURL: "https://www.google.com/s2/favicons?domain=zoom.us&sz=128"),
        AppTemplate(id: "discord", name: "Discord Nitro", iconURL: "https://www.google.com/s2/favicons?domain=discord.com&sz=128"),
        AppTemplate(id: "telegram", name: "Telegram Premium", iconURL: "https://www.google.com/s2/favicons?domain=telegram.org&sz=128"),
        AppTemplate(id: "microsoft-teams", name: "Microsoft Teams", iconURL: "https://www.google.com/s2/favicons?domain=teams.microsoft.com&sz=128"),

        // MARK: - AI Tools
        AppTemplate(id: "chatgpt", name: "ChatGPT Plus", iconURL: "https://www.google.com/s2/favicons?domain=chatgpt.com&sz=128"),
        AppTemplate(id: "claude", name: "Claude Pro", iconURL: "https://www.google.com/s2/favicons?domain=claude.ai&sz=128"),
        AppTemplate(id: "midjourney", name: "Midjourney", iconURL: "https://www.google.com/s2/favicons?domain=midjourney.com&sz=128"),
        AppTemplate(id: "copilot", name: "GitHub Copilot", iconURL: "https://www.google.com/s2/favicons?domain=github.com&sz=128"),
        AppTemplate(id: "perplexity", name: "Perplexity Pro", iconURL: "https://www.google.com/s2/favicons?domain=perplexity.ai&sz=128"),
        AppTemplate(id: "gemini", name: "Gemini Advanced", iconURL: "https://www.google.com/s2/favicons?domain=gemini.google.com&sz=128"),
        AppTemplate(id: "cursor", name: "Cursor Pro", iconURL: "https://www.google.com/s2/favicons?domain=cursor.com&sz=128"),

        // MARK: - Development
        AppTemplate(id: "github", name: "GitHub Pro", iconURL: "https://www.google.com/s2/favicons?domain=github.com&sz=128"),
        AppTemplate(id: "gitlab", name: "GitLab", iconURL: "https://www.google.com/s2/favicons?domain=gitlab.com&sz=128"),
        AppTemplate(id: "jetbrains", name: "JetBrains", iconURL: "https://www.google.com/s2/favicons?domain=jetbrains.com&sz=128"),
        AppTemplate(id: "heroku", name: "Heroku", iconURL: "https://www.google.com/s2/favicons?domain=heroku.com&sz=128"),
        AppTemplate(id: "vercel", name: "Vercel", iconURL: "https://www.google.com/s2/favicons?domain=vercel.com&sz=128"),
        AppTemplate(id: "netlify", name: "Netlify", iconURL: "https://www.google.com/s2/favicons?domain=netlify.com&sz=128"),
        AppTemplate(id: "digitalocean", name: "DigitalOcean", iconURL: "https://www.google.com/s2/favicons?domain=digitalocean.com&sz=128"),

        // MARK: - Design
        AppTemplate(id: "adobe", name: "Adobe Creative Cloud", iconURL: "https://www.google.com/s2/favicons?domain=adobe.com&sz=128"),
        AppTemplate(id: "figma", name: "Figma", iconURL: "https://www.google.com/s2/favicons?domain=figma.com&sz=128"),
        AppTemplate(id: "canva", name: "Canva Pro", iconURL: "https://www.google.com/s2/favicons?domain=canva.com&sz=128"),
        AppTemplate(id: "sketch", name: "Sketch", iconURL: "https://www.google.com/s2/favicons?domain=sketch.com&sz=128"),
        AppTemplate(id: "procreate", name: "Procreate", iconURL: "https://www.google.com/s2/favicons?domain=procreate.com&sz=128"),
        AppTemplate(id: "lightroom", name: "Lightroom", iconURL: "https://www.google.com/s2/favicons?domain=lightroom.adobe.com&sz=128"),
        AppTemplate(id: "google-photos", name: "Google Photos", iconURL: "https://www.google.com/s2/favicons?domain=photos.google.com&sz=128"),
        AppTemplate(id: "luma-fusion", name: "LumaFusion", iconURL: "https://www.google.com/s2/favicons?domain=luma-touch.com&sz=128"),
        AppTemplate(id: "vsco", name: "VSCO", iconURL: "https://www.google.com/s2/favicons?domain=vsco.co&sz=128"),

        // MARK: - News & Reading
        AppTemplate(id: "medium", name: "Medium", iconURL: "https://www.google.com/s2/favicons?domain=medium.com&sz=128"),
        AppTemplate(id: "nyt", name: "New York Times", iconURL: "https://www.google.com/s2/favicons?domain=nytimes.com&sz=128"),
        AppTemplate(id: "wsj", name: "Wall Street Journal", iconURL: "https://www.google.com/s2/favicons?domain=wsj.com&sz=128"),
        AppTemplate(id: "wapo", name: "Washington Post", iconURL: "https://www.google.com/s2/favicons?domain=washingtonpost.com&sz=128"),
        AppTemplate(id: "economist", name: "The Economist", iconURL: "https://www.google.com/s2/favicons?domain=economist.com&sz=128"),
        AppTemplate(id: "bloomberg", name: "Bloomberg", iconURL: "https://www.google.com/s2/favicons?domain=bloomberg.com&sz=128"),
        AppTemplate(id: "substack", name: "Substack", iconURL: "https://www.google.com/s2/favicons?domain=substack.com&sz=128"),
        AppTemplate(id: "pocket", name: "Pocket Premium", iconURL: "https://www.google.com/s2/favicons?domain=getpocket.com&sz=128"),
        AppTemplate(id: "apple-news", name: "Apple News+", iconURL: "https://www.google.com/s2/favicons?domain=apple.com&sz=128"),

        // MARK: - Health & Fitness
        AppTemplate(id: "peloton", name: "Peloton", iconURL: "https://www.google.com/s2/favicons?domain=onepeloton.com&sz=128"),
        AppTemplate(id: "headspace", name: "Headspace", iconURL: "https://www.google.com/s2/favicons?domain=headspace.com&sz=128"),
        AppTemplate(id: "calm", name: "Calm", iconURL: "https://www.google.com/s2/favicons?domain=calm.com&sz=128"),
        AppTemplate(id: "strava", name: "Strava", iconURL: "https://www.google.com/s2/favicons?domain=strava.com&sz=128"),
        AppTemplate(id: "myfitnesspal", name: "MyFitnessPal", iconURL: "https://www.google.com/s2/favicons?domain=myfitnesspal.com&sz=128"),
        AppTemplate(id: "fitbod", name: "Fitbod", iconURL: "https://www.google.com/s2/favicons?domain=fitbod.me&sz=128"),
        AppTemplate(id: "apple-fitness", name: "Apple Fitness+", iconURL: "https://www.google.com/s2/favicons?domain=apple.com&sz=128"),
        AppTemplate(id: "nike-run", name: "Nike Run Club", iconURL: "https://www.google.com/s2/favicons?domain=nike.com&sz=128"),
        AppTemplate(id: "keep", name: "Keep", iconURL: "https://www.google.com/s2/favicons?domain=keep.com&sz=128"),

        // MARK: - Education
        AppTemplate(id: "duolingo", name: "Duolingo Plus", iconURL: "https://www.google.com/s2/favicons?domain=duolingo.com&sz=128"),
        AppTemplate(id: "coursera", name: "Coursera Plus", iconURL: "https://www.google.com/s2/favicons?domain=coursera.org&sz=128"),
        AppTemplate(id: "skillshare", name: "Skillshare", iconURL: "https://www.google.com/s2/favicons?domain=skillshare.com&sz=128"),
        AppTemplate(id: "masterclass", name: "MasterClass", iconURL: "https://www.google.com/s2/favicons?domain=masterclass.com&sz=128"),
        AppTemplate(id: "linkedin-learning", name: "LinkedIn Learning", iconURL: "https://www.google.com/s2/favicons?domain=linkedin.com&sz=128"),
        AppTemplate(id: "blinkist", name: "Blinkist", iconURL: "https://www.google.com/s2/favicons?domain=blinkist.com&sz=128"),
        AppTemplate(id: "brilliant", name: "Brilliant", iconURL: "https://www.google.com/s2/favicons?domain=brilliant.org&sz=128"),

        // MARK: - Gaming
        AppTemplate(id: "playstation", name: "PlayStation Plus", iconURL: "https://www.google.com/s2/favicons?domain=playstation.com&sz=128"),
        AppTemplate(id: "xbox", name: "Xbox Game Pass", iconURL: "https://www.google.com/s2/favicons?domain=xbox.com&sz=128"),
        AppTemplate(id: "nintendo", name: "Nintendo Switch Online", iconURL: "https://www.google.com/s2/favicons?domain=nintendo.com&sz=128"),
        AppTemplate(id: "apple-arcade", name: "Apple Arcade", iconURL: "https://www.google.com/s2/favicons?domain=apple.com&sz=128"),
        AppTemplate(id: "ea-play", name: "EA Play", iconURL: "https://www.google.com/s2/favicons?domain=ea.com&sz=128"),
        AppTemplate(id: "steam", name: "Steam", iconURL: "https://www.google.com/s2/favicons?domain=steampowered.com&sz=128"),

        // MARK: - VPN & Security
        AppTemplate(id: "nordvpn", name: "NordVPN", iconURL: "https://www.google.com/s2/favicons?domain=nordvpn.com&sz=128"),
        AppTemplate(id: "expressvpn", name: "ExpressVPN", iconURL: "https://www.google.com/s2/favicons?domain=expressvpn.com&sz=128"),
        AppTemplate(id: "surfshark", name: "Surfshark", iconURL: "https://www.google.com/s2/favicons?domain=surfshark.com&sz=128"),
        AppTemplate(id: "protonvpn", name: "Proton VPN", iconURL: "https://www.google.com/s2/favicons?domain=protonvpn.com&sz=128"),
        AppTemplate(id: "proton-mail", name: "Proton Mail", iconURL: "https://www.google.com/s2/favicons?domain=proton.me&sz=128"),

        // MARK: - Social
        AppTemplate(id: "tinder", name: "Tinder", iconURL: "https://www.google.com/s2/favicons?domain=tinder.com&sz=128"),
        AppTemplate(id: "bumble", name: "Bumble", iconURL: "https://www.google.com/s2/favicons?domain=bumble.com&sz=128"),
        AppTemplate(id: "linkedin", name: "LinkedIn Premium", iconURL: "https://www.google.com/s2/favicons?domain=linkedin.com&sz=128"),
        AppTemplate(id: "twitter", name: "X Premium", iconURL: "https://www.google.com/s2/favicons?domain=x.com&sz=128"),
        AppTemplate(id: "reddit", name: "Reddit Premium", iconURL: "https://www.google.com/s2/favicons?domain=reddit.com&sz=128"),

        // MARK: - Finance & Lifestyle
        AppTemplate(id: "ynab", name: "YNAB", iconURL: "https://www.google.com/s2/favicons?domain=ynab.com&sz=128"),
        AppTemplate(id: "copilot-finance", name: "Copilot Money", iconURL: "https://www.google.com/s2/favicons?domain=copilot.money&sz=128"),
        AppTemplate(id: "doordash", name: "DashPass", iconURL: "https://www.google.com/s2/favicons?domain=doordash.com&sz=128"),
        AppTemplate(id: "ubereats", name: "Uber One", iconURL: "https://www.google.com/s2/favicons?domain=uber.com&sz=128"),
        AppTemplate(id: "instacart", name: "Instacart+", iconURL: "https://www.google.com/s2/favicons?domain=instacart.com&sz=128"),
    ]

    /// Get templates grouped by first letter
    static var groupedByLetter: [String: [AppTemplate]] {
        Dictionary(grouping: all.sorted { $0.name < $1.name }, by: { $0.firstLetter })
    }

    /// Get all first letters sorted
    static var sortedLetters: [String] {
        Array(Set(all.map { $0.firstLetter })).sorted()
    }
}
