/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/
import Publish
import Plot

public extension Theme {
    /// The default "Foundation" theme that Publish ships with, a very
    /// basic theme mostly implemented for demonstration purposes.
    static var custom: Self {
        Theme(
            htmlFactory: CustomHTMLFactory(),
            resourcePaths: [
                "/Sources/MyBlog/styles.css",
                "/Sources/MyBlog/code-styles.css"
            ]
        )
    }
}

private struct CustomHTMLFactory<Site: Website>: HTMLFactory {
    func makeIndexHTML(for index: Index,
                       context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .headTag(for: index, on: context.site),
            .body {
                SiteHeader(context: context, selectedSelectionID: nil, location: index)
                Wrapper {
                    Paragraph(context.site.description)
                        .class("description")
                    H2("All posts")
                    ItemList(
                        items: context.allItems(
                            sortedBy: \.date,
                            order: .descending
                        ),
                        site: context.site
                    )
                }
                SiteFooter()
            }
        )
    }

    func makeSectionHTML(for section: Section<Site>,
                         context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .headTag(for: section, on: context.site),
            .body {
                SiteHeader(context: context, selectedSelectionID: section.id, location: section)
                Wrapper {
                    H1("\(section.title)'s posts")
                    ItemList(items: section.items, site: context.site)
                }
                SiteFooter()
            }
        )
    }

    func makeItemHTML(for item: Item<Site>,
                      context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .headTag(for: item, on: context.site),
            .body(
                .class("item-page"),
                .components {
                    SiteHeader(context: context, selectedSelectionID: item.sectionID, location: item)
                    Wrapper {
                        Article {
                            Div(item.content.body).class("content")
                            if (!item.tags.isEmpty) {
                                Span("Tags: ")
                                ItemTagList(item: item, site: context.site)
                            }
                        }
                    }
                    SiteFooter()
                }
            )
        )
    }

    func makePageHTML(for page: Page,
                      context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .headTag(for: page, on: context.site),
            .body {
                SiteHeader(context: context, selectedSelectionID: nil, location: page)
                Wrapper(page.body)
                SiteFooter()
            }
        )
    }

    func makeTagListHTML(for page: TagListPage,
                         context: PublishingContext<Site>) throws -> HTML? {
        HTML(
            .lang(context.site.language),
            .headTag(for: page, on: context.site),
            .body {
                SiteHeader(context: context, selectedSelectionID: nil, location: page)
                Wrapper {
                    H1("Browse all tags")
                    List(page.tags.sorted()) { tag in
                        ListItem {
                            Link(tag.string,
                                 url: context.site.path(for: tag).absoluteString
                            )
                        }
                        .class("tag")
                    }
                    .class("all-tags")
                }
                SiteFooter()
            }
        )
    }

    func makeTagDetailsHTML(for page: TagDetailsPage,
                            context: PublishingContext<Site>) throws -> HTML? {
        HTML(
            .lang(context.site.language),
            .headTag(for: page, on: context.site),
            .body {
                SiteHeader(context: context, selectedSelectionID: nil, location: page)
                Wrapper {
                    H1 {
                        Text("Tagged with ")
                        Span(page.tag.string).class("tag")
                    }

                    Link("Browse all tags",
                        url: context.site.tagListPath.absoluteString
                    )
                    .class("browse-all")

                    ItemList(
                        items: context.items(
                            taggedWith: page.tag,
                            sortedBy: \.date,
                            order: .descending
                        ),
                        site: context.site
                    )
                }
                SiteFooter()
            }
        )
    }
}

private struct Wrapper: ComponentContainer {
    @ComponentBuilder var content: ContentProvider

    var body: Component {
        Div(content: content).class("wrapper")
    }
}

private struct SiteHeader<Site: Website>: Component {
    var context: PublishingContext<Site>
    var selectedSelectionID: Site.SectionID?
    var location: Location
    var body: Component {
        Header {
            Wrapper {
                Span("/").class("site-name")
                Link("home", url: "/")
                    .class("site-name")
                if let sectionID = selectedSelectionID, let section = context.sections[sectionID], let path = section.path.absoluteString, let resource = location.path.absoluteString.dropFirst(section.title.count + 1) {
                    Span("/").class("site-path")
                    Link("\(section.title.lowercased())", url: path).class("site-path")
                    Span("\(resource)").class("site-path")
                } else {
                    if (location.path.absoluteString != "/") {
                        Span(location.path.absoluteString).class("site-path")
                    }
                }
                if Site.SectionID.allCases.count > 1 {
                    //navigation
                }
            }
        }
    }

    private var navigation: Component {
        Navigation {
            List(Site.SectionID.allCases) { sectionID in
                let section = context.sections[sectionID]

                return Link(section.title,
                    url: section.path.absoluteString
                )
                .class(sectionID == selectedSelectionID ? "selected" : "")
            }
        }
    }
}

private struct ItemList<Site: Website>: Component {
    var items: [Item<Site>]
    var site: Site

    var body: Component {
        List(items) { item in
            Article {
                H1(Link(item.title, url: item.path.absoluteString))
                ItemTagList(item: item, site: site)
                Paragraph(item.description)
            }
        }
        .class("item-list")
    }
}

private struct ItemTagList<Site: Website>: Component {
    var item: Item<Site>
    var site: Site

    var body: Component {
        List(item.tags) { tag in
            Link(tag.string, url: site.path(for: tag).absoluteString)
        }
        .class("tag-list")
    }
}

private struct SiteFooter: Component {
    var body: Component {
        Footer {
            Paragraph {
                Text("Generated using ")
                Link("Publish", url: "https://github.com/johnsundell/publish")
            }
            Paragraph {
                Link("Github repo", url: "https://github.com/hung-m-dao/my-blog")
            }
        }
    }
}

public extension Node where Context == HTML.DocumentContext {
    static func headTag<T: Website>(for location: Location, on site: T) -> Node {
//        return head(for: location, on: site, stylesheetPaths: )
        let stylesheetPaths: [Path] = ["styles.css", "code-styles.css"]
        
        var title = location.title
        if title.isEmpty {
            title = site.name
        }
        
        var description = location.description

        if description.isEmpty {
            description = site.description
        }
        return .head(.script(.src("/prism.js")),
                     .encoding(.utf8),
                     .siteName(site.name),
                     .url(site.url(for: location)),
                     .title(title),
                     .description(description),
                     .twitterCardType(location.imagePath == nil ? .summary : .summaryLargeImage),
                     .forEach(stylesheetPaths, { .stylesheet($0) }),
                     .viewport(.accordingToDevice),
                     .unwrap(site.favicon, { .favicon($0) }),
                     .unwrap(location.imagePath ?? site.imagePath, { path in
                         let url = site.url(for: path)
                         return .socialImageLink(url)
                     }))
    }
}

