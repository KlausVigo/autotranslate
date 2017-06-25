#' Get translations from Google Translate
#'
#' Gets translations from Google Translate.
#' @param x A character vector containing text to translate.
#' @param lang_to A two letter language code describing the language to
#' translate to. See \code{MICROSOFT_LANGS} for available values.
#' @param lang_from A two letter language code describing the language to
#' translate from, defaulting to English. See \code{MICROSOFT_LANGS} for
#' available values.
#' @param google_key A string containing a subscription key to
#' Google Translate API.
#' @param parallelization_strategy A string naming a parallelization strategy,
#' passed to \code{\link[future]{plan}}.
#' @return A character vector of translated strings
#' @references
#' \url{https://cloud.google.com/translate/docs/reference/translate}
#' @examples
#' \donttest{
#' # Not tested due to need for Google Translate API key
#' get_google_translations(TRANSLATION_QUOTES, sample(GOOGLE_LANGS, 1))
#' }
#' @importFrom future plan
#' @importFrom future future_lapply
#' @export
get_google_translations <- function(x, lang_to, lang_from = "en",
  google_key = Sys.getenv("GOOGLE_TRANSLATE_API_KEY"),
  parallelization_strategy = c("sequential", "multicore", "cluster")) {
  parallelization_strategy <- match.arg(parallelization_strategy)
  plan(parallelization_strategy)
  unlist(
    future_lapply(
      x,
      function(xi) {
        tryCatch(
          get_google_translation(xi, lang_to, lang_from, google_key),
          error = function(e) NA_character_
        )
      }
    )
  )
}

#' Get single translation from Google Translate
#'
#' Gets a single translation from Google Translate.
#' @param x A single string containing text to translate (10000 char max). If
#' \code{x} is a character vector, it will be collapsed to a single string
#' separated by newlines.
#' @param access_token A string containing an access token, as provided by
#' \code{\link{get_microsoft_access_token}}.
#' @param lang_to A two letter language code describing the language to
#' translate to. See \code{MICROSOFT_LANGS} for available values.
#' @param lang_from A two letter language code describing the language to
#' translate from, defaulting to English. See \code{MICROSOFT_LANGS} for
#' available values.
#' @references
#' \url{https://docs.microsofttranslator.com/text-translate.html#!/default/get_Translate}
#' @examples
#' \donttest{
#' # Not tested due to need for Google Translate API key
#' get_google_translation(TRANSLATION_QUOTES[1], sample(GOOGLE_LANGS, 1))
#' }
#' @importFrom httr modify_url
#' @importFrom httr GET
#' @importFrom httr stop_for_status
#' @importFrom httr content
#' @noRd
get_google_translation <- function(x, lang_to, lang_from = "en", google_key = Sys.getenv("GOOGLE_TRANSLATE_API_KEY")) {
  x <- paste(x, collapse = "\n")
  lang_to <- match.arg(lang_to, GOOGLE_LANGS)
  lang_from <- match.arg(lang_from, GOOGLE_LANGS)
  base_url <- "https://www.googleapis.com/language/translate/v2"
  full_url <- modify_url(
    base_url,
    query = list(
      q = x,
      source = lang_from,
      target = lang_to,
      format = "text",
      key = google_key
    )
  )
  response <- GET(full_url)
  stop_for_status(response)
  content(response, as = "parsed")$data$translations[[1]]$translatedText
}

#' @rdname LANGS
#' @export
GOOGLE_LANGS <- c(
  Afrikaans = "af",
  Albanian = "sq",
  Arabic = "ar",
  Armenian = "hy",
  Azerbaijani = "az",
  Basque = "eu",
  Belarusian = "be",
  Bengali = "bn",
  Bosnian = "bs",
  Bulgarian = "bg",
  Catalan = "ca",
  Cebuano = "ceb",
  Chinese_Simplified = "zh-CN",
  Chinese_Traditional = "zh-TW",
  Croatian = "hr",
  Czech = "cs",
  Danish = "da",
  Dutch = "nl",
  English = "en",
  Esperanto = "eo",
  Estonian = "et",
  Filipino = "tl",
  Finnish = "fi",
  French = "fr",
  Galician = "gl",
  Georgian = "ka",
  German = "de",
  Greek = "el",
  Gujarati = "gu",
  Haitian_Creole = "ht",
  Hausa = "ha",
  Hebrew = "iw",
  Hindi = "hi",
  Hmong = "hmn",
  Hungarian = "hu",
  Icelandic = "is",
  Igbo = "ig",
  Indonesian = "id",
  Irish = "ga",
  Italian = "it",
  Japanese = "ja",
  Javanese = "jw",
  Kannada = "kn",
  Khmer = "km",
  Korean = "ko",
  Lao = "lo",
  Latin = "la",
  Latvian = "lv",
  Lithuanian = "lt",
  Macedonian = "mk",
  Malay = "ms",
  Maltese = "mt",
  Maori = "mi",
  Marathi = "mr",
  Mongolian = "mn",
  Nepali = "ne",
  Norwegian = "no",
  Persian = "fa",
  Polish = "pl",
  Portuguese = "pt",
  Punjabi = "pa",
  Romanian = "ro",
  Russian = "ru",
  Serbian = "sr",
  Slovak = "sk",
  Slovenian = "sl",
  Somali = "so",
  Spanish = "es",
  Swahili = "sw",
  Swedish = "sv",
  Tamil = "ta",
  Telugu = "te",
  Thai = "th",
  Turkish = "tr",
  Ukrainian = "uk",
  Urdu = "ur",
  Vietnamese = "vi",
  Welsh = "cy",
  Yiddish = "yi",
  Yoruba = "yo",
  Zulu = "zu"
)

#' Quotes about translations
#'
#' Some quotes about translating text, for use in the examples.
#' @docType data
#' @format A character vector.
#' @export
TRANSLATION_QUOTES <- c(
  borges = "The original is unfaithful to the translation.",
  jowett = "All translation is a compromise - the effort to be literal and the effort to be idiomatic.",
  friar  = "Even the simplest word can never be rendered with its exact equivalent into another language."
)