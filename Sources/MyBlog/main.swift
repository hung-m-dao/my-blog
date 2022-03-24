import Foundation
import Publish
import Plot

// This type acts as the configuration for your website.
struct MyBlog: Website {
    enum SectionID: String, WebsiteSectionID {
        // Add the sections that you want your website to contain here:
        case posts
    }

    struct ItemMetadata: WebsiteItemMetadata {
        // Add any site-specific metadata that you want to use here.
    }

    // Update these properties to configure your website:
    var url = URL(string: "https://hung-m-dao.github.io/")!
    var name = "My blog"
    var description = "Hello! I'm Hung, and this is my personal space."
    var language: Language { .english }
    var imagePath: Path? = "images/me.jpg"
}

// This will generate your website using the built-in Foundation theme:
try MyBlog().publish(
        withTheme: .custom,
        deployedUsing: .gitHub("hung-m-dao/hung-m-dao.github.io")
    )
