--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.List
import           Data.Monoid           ((<>))
import           Data.Time
import           Hakyll

-- Force forward slash separators, even on Windows
import           System.FilePath.Posix


--------------------------------------------------------------------------------
main :: IO ()
main = hakyll $ do
    match "images/**" $ do
        route   idRoute
        compile copyFileCompiler


    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler


    match "posts/**" $ do
        route cleanRoute
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/post.html" postContext
            >>= defaultCompiler postContext


    -- Make the last created post the homepage.
    match "posts/**" $ version "latest-index" $ do
        route $ constRoute "index.html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/post.html" postContext
            >>= defaultCompiler postContext


    create ["archive.html"] $ do
        route cleanRoute
        compile $ do
            posts <- recentFirst =<< loadAll ("posts/**" .&&. hasNoVersion)
            let archiveContext =
                    listField "posts" postContext (return posts) <>
                    constField "title" "Archief"                 <>
                    defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveContext
                >>= defaultCompiler archiveContext


    match "templates/*" $ compile templateBodyCompiler


--------------------------------------------------------------------------------
postContext :: Context String
postContext =
  dateFieldWith
    defaultTimeLocale { months = [("januari",   "jan"), ("februari", "feb"),
                                  ("maart",     "mar"), ("april",    "apr"),
                                  ("mei",       "mei"), ("juni",     "jun"),
                                  ("juli",      "jul"), ("augustus", "aug"),
                                  ("september", "sep"), ("oktober",  "okt"),
                                  ("november",  "nov"), ("december", "dec")]}
    "date"
    "%e %B, %Y" <> defaultContext


cleanRoute :: Routes
cleanRoute =
  customRoute createIndexRoute
  where createIndexRoute ident =
          takeDirectory p </> takeBaseName p </> "index.html"
            where p = toFilePath ident


cleanIndexUrls :: Item String -> Compiler (Item String)
cleanIndexUrls = return . fmap (withUrls cleanIndex)


cleanIndexHtmls :: Item String -> Compiler (Item String)
cleanIndexHtmls = return . fmap (replaceAll patt replacement)
    where
      patt = "/index.html"
      replacement = const "/"


cleanIndex :: String -> String
cleanIndex url
    | idx `isSuffixOf` url = take (length url - length idx) url
    | otherwise            = url
  where idx = "index.html"


defaultCompiler :: Context String -> Item String -> Compiler (Item String)
defaultCompiler x y =
  loadAndApplyTemplate "templates/default.html" x y
    >>= cleanIndexUrls
    >>= cleanIndexHtmls
    >>= relativizeUrls
