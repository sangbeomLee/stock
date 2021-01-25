//
//  Provider.swift
//  stocks
//
//  Created by Daniel on 5/28/20.
//  Copyright © 2020 dk. All rights reserved.
//

import UIKit

enum Provider: String {

    case finnhub

    func getDetail(_ symbol: String?, completion: @escaping ([DetailSection], UIImage?) -> Void) {
        switch self {
        case .finnhub:
            Finnhub.getDetail(symbol) { profile, news, dividends, image, executives in
                var sections: [DetailSection] = []

                if let s = profile?.sections {
                    sections.append(contentsOf: s)
                }

                if let s = DetailSection.section(dividends) {
                    sections.append(s)
                }

                if let s = DetailSection.section(executives) {
                    sections.append(s)
                }

                if let s = DetailSection.section(news) {
                    sections.append(s)
                }
    
                completion(sections,image)
            }
        }
    }

    func search(_ query: String, completion: @escaping ([AddItem]?) -> Void) {
//        switch self {
//        case .finnhub:
//            Finnhub.getSearchResults(query) { (results) in
//                let items = results?.compactMap { $0.item }
//                completion(items)
//            }
//        }
    }

}

private extension String {
    var wikipediaUrl: URL? {
        let baseUrl = "https://en.wikipedia.org/wiki"
        let item = self.replacingOccurrences(of: " ", with: "_")

        return URL(string: "\(baseUrl)/\(item)")
    }
}

private extension Int {

    var largeNumberDisplay: String? {
        if self < 1_000_000 {
            return self.display
        }

        let m: Double = Double(self) / 1_000_000

        return String(format: "%.2fM", m)
    }

}

private extension Double {

    var largeNumberDisplay: String? {
        if self < 1_000_000 {
            return String(self)
        }

        let m = self / 1_000_000
        if m < 1000 {
            return "\(m.currency ?? "")M"
        }

        let b = m / 1000
        if b < 1000 {
            return "\(b.currency ?? "")B"
        }

        let t = b / 1000

        return "\(t.currency ?? "")T"
    }

    var fh_largeNumberDisplay: String? {
        if self < 1000 {
            return "\(self.display ?? "")M"
        }

        let b = self / 1000
        return "\(b.display ?? "")B"
    }

}

private extension Finnhub.Profile {

    var sections: [DetailSection]? {
        var sections: [DetailSection] = []

        if let section = mainSection {
            sections.append(section)
        }

        if let section = exchangeSection {
            sections.append(section)
        }

        return sections
    }

    var marketCapDisplay: String? {
        if marketCapitalization < 1000 {
            return "\(marketCapitalization.currency ?? "")M"
        }

        let b = marketCapitalization / 1000
        if b < 1000 {
            return "\(b.currency ?? "")B"
        }

        let t = b / 1000

        return "\(t.currency ?? "")T"
    }

    var mainSection: DetailSection? {
        var items: [DetailItem] = []

        let nameItem = DetailItem(subtitle: weburl.absoluteString, title: name, url: weburl)
        items.append(nameItem)

        if let value = marketCapDisplay {
            let marketCapItem = DetailItem(subtitle: "Market Capitalization", title: value)
            items.append(marketCapItem)
        }

        let section = DetailSection(header: finnhubIndustry, items: items)

        return section
    }

    var exchangeSection: DetailSection? {
        var items: [DetailItem] = []

        if let value = ipoTimeAgo {
            let ipoItem = DetailItem(subtitle: "\(ipoDisplay ?? "") IPO", title: value)
            items.append(ipoItem)
        }

        var string: [String] = ["Shares Outstanding"]
        string.append(country)
        string.append(currency)
        let sharesItem = DetailItem(subtitle: string.joined(separator: Theme.separator), title: "\(shareOutstanding.fh_largeNumberDisplay ?? "")")
        items.append(sharesItem)

        let section = DetailSection(header: exchange, items: items)

        return section
    }

    var ipoDate: Date? {
        return Finnhub.dateFormatter.date(from: ipo)
    }

    var ipoDisplay: String? {
        guard let ipoDate = ipoDate else { return nil }
        let df = StockDetailViewController.displayDateFormatter

        return df.string(from: ipoDate)
    }

    var ipoTimeAgo: String? {
        guard let ipoDate = ipoDate else { return nil }

        let rdf = RelativeDateTimeFormatter()

        return rdf.localizedString(for: ipoDate, relativeTo: Date())
    }
}

private extension DetailItem {

    var isUrl: Bool? {
        guard
            let value = subtitle,
            value.contains("http") else { return false }

        return true
    }

}

private extension DetailSection {

    static func section(_ div: [Finnhub.Dividend]?) -> DetailSection? {
        guard let div = div, div.count > 0 else { return nil }

        let items = div.compactMap { $0.item }

        let section = DetailSection(header: "recent dividends", items: items)

        return section
    }

    static func section(_ execs: [Finnhub.Executive]?) -> DetailSection? {
        guard let execs = execs, execs.count > 0 else { return nil }

        let items = execs.map { $0.item }
        let limit = 5
        let top = Array(items.prefix(limit))

        // TODO: have a way to see whole list (create footer, tap footer to see?)

        let section = DetailSection(header: "executives", items: top)

        return section
    }

    static func section(_ news: [Finnhub.News]?) -> DetailSection? {
        let items = news?.compactMap { $0.item }
        guard items?.count ?? 0 > 0 else { return nil }

        let section = DetailSection(header: "news", items: items)

        return section
    }

}

private extension StockDetailViewController {

    static var displayDateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "MMM d, yyyy"

        return df
    }

}

private extension Finnhub.Dividend {

    var item: DetailItem {
        let t = "\(amount.display ?? "") (\(currency))"

        let df = StockDetailViewController.displayDateFormatter
        var s = ""
        if let date = Finnhub.dateFormatter.date(from: payDate) {
            s = df.string(from: date)

            let rdf = RelativeDateTimeFormatter()
            s = "\(s)\(Theme.separator)\(rdf.localizedString(for: date, relativeTo: Date()))"
        }

        return DetailItem(subtitle: s, title: t)
    }

}

private extension Finnhub.Executive {

    var item: DetailItem {
        var sub: [String] = []

        if let value = positionDisplay {
            sub.append(value)
        }

        if let age = ageDisplay {
            sub.append(age)
        }

        return DetailItem(subtitle: sub.joined(separator: Theme.separator), title: nameDisplay, url: wikipedia)
    }

    var ageDisplay: String? {
        guard let age = age else { return nil }
        return "Age \(age)"
    }

    var nameDisplay: String {
        return name.trimmingCharacters(in: .whitespaces)
    }

    var positionDisplay: String? {
        guard let position = position else { return nil}

        var comp = position
        if let compensation = compensation?.largeNumberDisplay {
            if currency == "USD" {
                comp = "\(comp) ($"
            }
            comp = "\(comp)\(compensation))"
        }
        return comp
    }

    var wikipedia: URL? {
        let cleanup = nameDisplay
            .replacingOccurrences(of: "Amb. ", with: "")
            .replacingOccurrences(of: "Dr. ", with: "")
            .replacingOccurrences(of: "Mr. ", with: "")
            .replacingOccurrences(of: "Ms. ", with: "")
            .replacingOccurrences(of: "Sen. ", with: "")

        return cleanup.wikipediaUrl
    }

}

private extension Finnhub.News {

    var item: DetailItem? {
        var sub: [String] = []

        let date = Date(timeIntervalSince1970: TimeInterval(datetime))
        let rdf = RelativeDateTimeFormatter()
        let ago = rdf.localizedString(for: date, relativeTo: Date())
        sub.append(ago)

        if let value = sourceDisplay {
            sub.append(value)
        }
        sub.append(summary)

        return DetailItem(subtitle: sub.joined(separator: Theme.separator), title: headline, url: url)
    }

    var sourceDisplay: String? {
        return source
            .replacingOccurrences(of: "http://", with: "")
            .replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "www.", with: "")
    }

}

private extension Int {

    var display: String? {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.minimumFractionDigits = 0
        f.maximumFractionDigits = 0
        f.locale = Locale(identifier: "en_US")

        let number = NSNumber(value: self)
        return f.string(from: number)
    }

}
