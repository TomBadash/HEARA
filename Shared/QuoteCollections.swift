import Foundation

/// Small starter collections. Excerpts and editorial translations are explicitly labeled.
/// Content is added only when the user chooses a collection.
enum QuoteCollections {
    static let names = ["Judaism", "Islam", "Christianity"]
    static let quotes: [Quote] = [
        Quote(id: "j-avot-114a-he", text: "אם אין אני לי, מי לי?", category: "Judaism", source: "הלל — אבות א׳:י״ד (קטע)", sourceUrl: "https://www.sefaria.org/Pirkei_Avot.1.14", subcategory: "Responsibility"),
        Quote(id: "j-avot-114b-he", text: "ואם לא עכשיו, אימתי?", category: "Judaism", source: "הלל — אבות א׳:י״ד (קטע)", sourceUrl: "https://www.sefaria.org/Pirkei_Avot.1.14", subcategory: "Taking action"),
        Quote(id: "j-avot-114a-en", text: "If I am not for myself, who will be for me?", category: "Judaism", source: "Hillel — Avot 1:14; excerpt, editorial translation", sourceUrl: "https://www.sefaria.org/Pirkei_Avot.1.14", subcategory: "Responsibility"),
        Quote(id: "j-avot-114b-en", text: "If not now, when?", category: "Judaism", source: "Hillel — Avot 1:14; excerpt, editorial translation", sourceUrl: "https://www.sefaria.org/Pirkei_Avot.1.14", subcategory: "Taking action"),
        Quote(id: "i-q945-en", text: "For indeed, with hardship [will be] ease.", category: "Islam", source: "Qur’an 94:5 — Sahih International", sourceUrl: "https://legacy.quran.com/94/5", subcategory: "Hope"),
        Quote(id: "i-q2286-en", text: "Allah does not charge a soul except [with that within] its capacity.", category: "Islam", source: "Qur’an 2:286 — excerpt, Sahih International", sourceUrl: "https://legacy.quran.com/2/286", subcategory: "Resilience"),
        Quote(id: "i-q945-he", text: "אכן, עם הקושי באה הקלה.", category: "Islam", source: "הקוראן 94:5 — תרגום מערכתי חופשי לעברית", sourceUrl: "https://legacy.quran.com/94/5", subcategory: "Hope"),
        Quote(id: "i-q2286-he", text: "אללה אינו מטיל על נפש מעבר ליכולתה.", category: "Islam", source: "הקוראן 2:286 — קטע, תרגום מערכתי חופשי לעברית", sourceUrl: "https://legacy.quran.com/2/286", subcategory: "Resilience"),
        Quote(id: "c-m59-en", text: "Blessed are the peacemakers: for they shall be called the children of God.", category: "Christianity", source: "Matthew 5:9 — King James Version", sourceUrl: "https://www.biblegateway.com/passage/?search=Matthew+5%3A9&version=KJV", subcategory: "Peace"),
        Quote(id: "c-m77-en", text: "Ask, and it shall be given you; seek, and ye shall find; knock, and it shall be opened unto you.", category: "Christianity", source: "Matthew 7:7 — King James Version", sourceUrl: "https://www.biblegateway.com/passage/?search=Matthew+7%3A7&version=KJV", subcategory: "Seeking"),
        Quote(id: "c-m59-he", text: "אשרי משכיני השלום, כי בני אלוהים ייקראו.", category: "Christianity", source: "מתי ה׳:ט׳ — תרגום מערכתי חופשי לעברית", sourceUrl: "https://www.biblegateway.com/passage/?search=Matthew+5%3A9&version=KJV", subcategory: "Peace"),
        Quote(id: "c-m77-he", text: "בקשו ויינתן לכם; חפשו ותמצאו; דפקו וייפתח לכם.", category: "Christianity", source: "מתי ז׳:ז׳ — תרגום מערכתי חופשי לעברית", sourceUrl: "https://www.biblegateway.com/passage/?search=Matthew+7%3A7&version=KJV", subcategory: "Seeking")
    ]
}
