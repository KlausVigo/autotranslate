# autotranslate

An R package to Access Google Translate and Microsoft Translator Text 
Translation APIs

## Example

To translate text to another language, simply call `get_google_translations()` or
`get_microsoft_translations()`, passing your character vector and
the ISO 639-1 language code for the language that you want to translate to.

(Don't worry, you can look up the language code using the built-in variables
`GOOGLE_LANGS` and `MICROSOFT_LANGS`.)

```r
# Some demo messages
msgs <- c(
  "The original is unfaithful to the translation.",
  "All translation is a compromise - the effort to be literal and the effort to be idiomatic.",
  "Even the simplest word can never be rendered with its exact equivalent into another language."
)
# Using Google Translate
get_google_translations(msgs, "ar")
## [1] "الأصلي غير مخلص للترجمة."                                           
## [2] "كل الترجمة هي حل وسط - الجهد ليكون حرفي والجهد ليكون اصطلاحيا."     
## [3] "حتى أبسط كلمة لا يمكن أبدا أن تقدم مع مكافئتها بالضبط إلى لغة أخرى."
# Using Microsoft Translator
get_microsoft_translations(msgs, "zh-CHS")
## [1] "原来是不忠实的翻译。"                                        
## [2] "所有翻译都是达成妥协的努力能直译和努力做地道。"              
## [3] "甚至这个简单的词从来没有可以用它确切的等效成另一种语言呈现。"
```

# Setup

These services aren't free, so you'll have to do a little bit of set up first.
For either service, it takes 5 minutes of pointing and clicking to get yourself
an API KEY. Here are the docs to help you get set up for [Google](https://cloud.google.com/translate/docs) and for [Microsoft](https://www.microsoft.com/en-us/translator/getstarted.aspx).

# Alternatives

This package is a rewrite of [`translateR`](https://CRAN.R-project.org/package=translateR). The main are differences are

- more control of parallel execution via the [`future`](https://CRAN.R-project.org/package=future) package, and
- access to the Microsoft API actually works.
