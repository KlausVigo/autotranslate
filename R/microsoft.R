#' Get Microsoft Translator Access Token
#'
#' Gets an access token to use Microsoft Translator
#' @param microsoft_key A string containing a subscription key to
#' Microsoft Cognitive Services Translator API.
#' @return A list with two elements.
#' \describe{
#'   \item{value}{string containing an access token for Microsoft Cognitive
#'   Services Translator API, valid for 10 minutes.}
#'   \item{valid_until}{A \code{POSIXct} time when the token runs out. To give a
#'   little leeway, this is set to 590 seconds after the token was generated.}
#' }
#' @details To get a subscription key, you need to sign up for Microsoft Azure
#' and subscribe to the Cognitive Services Text API. See
#' \url{https://www.microsoft.com/en-us/translator/getstarted.aspx}
#' @references \url{https://docs.microsofttranslator.com/oauth-token.html}
#' @examples
#' \donttest{
#' # Not tested due to need for Microsoft Cognitive
#' # Services Translator API key
#' (access_token <- get_microsoft_access_token())
#' }
#' @importFrom httr POST
#' @importFrom httr add_headers
#' @importFrom httr stop_for_status
#' @importFrom httr content
#' @export
get_microsoft_access_token <- function(microsoft_key = Sys.getenv("MICROSOFT_TRANSLATOR_API_KEY")) {
  base_url <- "https://api.cognitive.microsoft.com/sts/v1.0/issueToken"
  response <- POST(
    base_url,
    add_headers(`Ocp-Apim-Subscription-Key` = microsoft_key)
  )
  stop_for_status(response)
  list(
    value = content(response, as = "text"),
    valid_until = Sys.time() + 590
  )
}

#' Get translations from Microsoft Translator
#'
#' Gets translations from Microsoft Translator.
#' @param x A character vector containing text to translate.
#' @param lang_to A two letter language code describing the language to
#' translate to. See \code{MICROSOFT_LANGS} for available values.
#' @param lang_from A two letter language code describing the language to
#' translate from, defaulting to English. See \code{MICROSOFT_LANGS} for
#' available values.
#' @param microsoft_key A string containing a subscription key to
#' Microsoft Cognitive Services Translator API, passed to
#' \code{\link{get_microsoft_access_token}}.
#' @param parallelization_strategy A string naming a parallelization strategy,
#' passed to \code{\link[future]{plan}}.
#' @references
#' \url{https://docs.microsofttranslator.com/text-translate.html#!/default/get_Translate}
#' @examples
#' \donttest{
#' # Not tested due to need for Microsoft Cognitive
#' # Services Translator API key
#' get_microsoft_translations(TRANSLATION_QUOTES, sample(MICROSOFT_LANGS, 1))
#' }
#' @importFrom future plan
#' @importFrom future future_lapply
#' @export
get_microsoft_translations <- function(x, lang_to, lang_from = "en",
  microsoft_key = Sys.getenv("MICROSOFT_TRANSLATOR_API_KEY"),
  parallelization_strategy = c("sequential", "multicore", "cluster")) {
  parallelization_strategy <- match.arg(parallelization_strategy)
  plan(parallelization_strategy)
  access_token <- get_microsoft_access_token(microsoft_key)
  unlist(
    future_lapply(
      x,
      function(xi) {
        access_token <- refresh_access_token(access_token, microsoft_key)
        tryCatch(
          get_microsoft_translation(xi, lang_to, lang_from, access_token),
          error = function(e) NA_character_
        )
      }
    )
  )
}

refresh_access_token <- function(access_token, microsoft_key) {
  if(Sys.time() > access_token$valid_until) {
    return(get_microsoft_access_token(microsoft_key))
  } else {
    return(access_token)
  }
}

#' Get single translation from Microsoft Translator
#'
#' Gets a single translation from Microsoft Translator.
#' @param x A single string containing text to translate (10000 char max). If
#' \code{x} is a character vector, it will be collapsed to a single string
#' separated by newlines.
#' @param lang_to A two letter language code describing the language to
#' translate to. See \code{MICROSOFT_LANGS} for available values.
#' @param lang_from A two letter language code describing the language to
#' translate from, defaulting to English. See \code{MICROSOFT_LANGS} for
#' available values.
#' @param access_token A string containing an access token, as provided by
#' \code{\link{get_microsoft_access_token}}.
#' @references
#' \url{https://docs.microsofttranslator.com/text-translate.html#!/default/get_Translate}
#' @examples
#' \donttest{
#' # Not tested due to need for Microsoft Cognitive
#' # Services Translator API key
#' access_token <- get_microsoft_access_token()
#' get_microsoft_translation(
#'   TRANSLATION_QUOTES[1],
#'   sample(MICROSOFT_LANGS, 1),
#'   access_token
#' )
#' }
#' @importFrom httr modify_url
#' @importFrom httr GET
#' @importFrom httr add_headers
#' @importFrom httr stop_for_status
#' @importFrom httr content
#' @importFrom xml2 xml_text
#' @noRd
get_microsoft_translation <- function(x, lang_to, lang_from = "en", access_token) {
  x <- paste(x, collapse = "\n")
  if(Sys.time() > access_token$valid_until) {
    stop("Your access token has expired.")
  }
  lang_to <- match.arg(lang_to, MICROSOFT_LANGS)
  lang_from <- match.arg(lang_from, MICROSOFT_LANGS)
  base_url <- "https://api.microsofttranslator.com/V2/Http.svc/Translate"
  full_url <- modify_url(
    base_url,
    query = list(
      text = x,
      from = lang_from,
      to = lang_to,
      contentType = "text/plain"
    )
  )
  response <- GET(
    full_url,
    add_headers(Authorization = paste("Bearer", access_token$value))
  )
  stop_for_status(response)
  xml_text(content(response, as = "parsed"))
}

#' Languages codes
#'
#' ISO 639-1 two letter langauge codes supported by Google Translate and
#' Microsoft Translator.
#' @docType data
#' @format A named character vector. Names are human readable language names,
#' values are ISO 639-1 codes.
#' @name LANGS
#' @seealso \code{\link{get_google_translations}},
#' \code{\link{get_microsoft_translations}}.
#' @export
MICROSOFT_LANGS <- c(
  Arabic = "ar",
  Bulgarian = "bg",
  Catalan = "ca",
  Chinese_Simplified = "zh-CHS",
  Chinese_Traditional = "zh-CHT",
  Czech = "cs",
  Danish = "da",
  Dutch = "nl",
  English = "en",
  Estonian = "et",
  Finnish = "fi",
  French = "fr",
  German = "de",
  Greek = "el",
  Haitian_Creole = "ht",
  Hebrew = "he",
  Hindi = "hi",
  Hmong_Daw = "mww",
  Hungarian = "hu",
  Indonesian = "id",
  Italian = "it",
  Japanese = "ja",
  Klingon = "tlh",
  Klingon_pIqaD = "tlh-Qaak",
  Korean = "ko",
  Latvian = "lv",
  Lithuanian = "lt",
  Malay = "ms",
  Maltese = "mt",
  Norwegian = "no",
  Persian = "fa",
  Polish = "pl",
  Portuguese = "pt",
  Romanian = "ro",
  Russian = "ru",
  Slovak = "sk",
  Slovenian = "sl",
  Spanish = "es",
  Swedish = "sv",
  Thai = "th",
  Turkish = "tr",
  Ukrainian = "uk",
  Urdu = "ur",
  Vietnamese = "vi",
  Welsh = "cy"
)
