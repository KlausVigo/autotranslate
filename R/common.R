#' Translate your text, choosing the engine
#'
#' Translate text, choosing whether you use Google Translate or Microsoft
#' Translator.
#' @param x A character vector containing text to translate.
#' @param lang_to A two letter language code describing the language to
#' translate to. See \code{MICROSOFT_LANGS} for available values.
#' @param lang_from A two letter language code describing the language to
#' translate from, defaulting to English. See \code{MICROSOFT_LANGS} for
#' available values.
#' @param api_key A string containing a subscription key to the Google Translate
#' or Microsfot Translator API (depending upon the \code{engine}).
#' @param parallelization_strategy A string naming a parallelization strategy,
#' passed to \code{\link[future]{plan}}.
#' @param engine A string naming the translation engine to use. Either "google"
#' or "microsoft".
#' @return A character vector of translated strings.
#' @seealso \code{\link{get_google_translations}},
#' \code{\link{get_microsoft_translations}}
#' @examples
#' \donttest{
#' # Not tested due to need for Microsoft Cognitive
#' # Services Translator API key and Google Translate API key
#' get_translations(
#'   TRANSLATION_QUOTES,
#'   "es",
#'   api_key = Sys.getenv("GOOGLE_TRANSLATE_API_KEY"),
#'   engine = "google"
#' )
#' get_translations(
#'   TRANSLATION_QUOTES,
#'   "es",
#'   api_key = Sys.getenv("MICROSOFT_TRANSLATOR_API_KEY"),
#'   engine = "microsoft"
#' )
#' }
#' @export
get_translations <- function(x, lang_to, lang_from = "en", api_key,
  parallelization_strategy = c("sequential", "multicore", "cluster"),
  engine = c("google", "microsoft")) {
  parallelization_strategy <- match.arg(parallelization_strategy)
  engine <- match.arg(engine)

  translation_fn <- switch(
    engine,
    google = get_google_translations,
    microsoft = get_microsoft_translations
  )
  translation_fn(x, lang_to, lang_from, api_key, parallelization_strategy)
}

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
