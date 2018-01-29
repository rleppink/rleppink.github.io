--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.List
import           Data.Monoid           ((<>))
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


    match "posts/*" $ do
        route cleanRoute
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/post.html"    postCtx
            >>= defaultCompiler postCtx


    create ["archive.html"] $ do
        route cleanRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let archiveCtx =
                    listField "posts" postCtx (return posts) <>
                    constField "title" "Archief"             <>
                    defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= defaultCompiler archiveCtx


    match "index.html" $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let indexCtx =
                    listField "posts" postCtx (return posts) <>
                    constField "title" "Home"                <>
                    defaultContext

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= defaultCompiler indexCtx


    match "templates/*" $ compile templateBodyCompiler


--------------------------------------------------------------------------------
postCtx :: Context String
postCtx = dateField "date" "%e %B, %Y" <> defaultContext


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
