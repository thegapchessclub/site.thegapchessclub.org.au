{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}

import Control.Category((.))
import Control.Monad(return, (>>=), (=<<))
import Data.Function(($))
import Data.Functor(fmap)
import Data.List(take)
import Data.Monoid(mappend)
import Hakyll(feedRoot, feedAuthorName, feedDescription, feedAuthorEmail, feedTitle, FeedConfiguration(FeedConfiguration), destinationDirectory, Configuration, renderRss, loadAllSnapshots, renderAtom, recentFirst, compile, bodyField, idRoute, route, create, templateBodyCompiler, match, relativizeUrls, loadAndApplyTemplate, constField, applyAsTemplate, getResourceBody, defaultContext, listField, loadAll, setExtension, defaultContext, copyFileCompiler, compressCssCompiler, hakyllWith, defaultConfiguration)
import People(peopleRules)
import Posts(postRules)
import Posts.Context(postCtx)
import System.IO(IO)
import Util.Index(niceRoute, removeIndexHtml)
import Util.Pandoc(pandocCompiler')

config ::
  Configuration
config =
  defaultConfiguration {
    destinationDirectory = "public"
  }

main ::
  IO ()
main = do
  hakyllWith config $ do
    match "images/**" $ do
      route   idRoute
      compile copyFileCompiler

    match "fonts/**" $ do
      route   idRoute
      compile copyFileCompiler

    match "js/**" $ do
      route   idRoute
      compile copyFileCompiler

    match "css/**" $ do
      route   idRoute
      compile compressCssCompiler

    match "share/**" $ do
      route   idRoute
      compile copyFileCompiler

    match "location.html" $ do
      route niceRoute
      compile $ do
        let locationCtx =
              constField "location-active" "" `mappend` defaultContext
        getResourceBody
          >>= loadAndApplyTemplate "templates/default.html" locationCtx
          >>= relativizeUrls
          >>= removeIndexHtml

    match "contact.html" $ do
      route niceRoute
      compile $ do
        let contactCtx =
              constField "contact-active" "true" `mappend` defaultContext
        getResourceBody
          >>= loadAndApplyTemplate "templates/default.html" contactCtx
          >>= relativizeUrls
          >>= removeIndexHtml

    peopleRules pandocCompiler'

    postRules pandocCompiler'

    match "index.html" $ do
      route $ setExtension "html"
      compile $ do
        posts <- fmap (take 5) . recentFirst =<< loadAll "posts/**"
        let indexCtx =
              constField "home-active" ""              `mappend`
              listField "posts" postCtx (return posts) `mappend`
              constField "title" "Home"                `mappend`
              defaultContext

        getResourceBody
          >>= applyAsTemplate indexCtx
          >>= loadAndApplyTemplate "templates/default.html" indexCtx
          >>= relativizeUrls
          >>= removeIndexHtml

    match "templates/*" $ compile templateBodyCompiler

    -- http://jaspervdj.be/hakyll/tutorials/05-snapshots-feeds.html
    let
      rss name render' =
        create [name] $ do
          route idRoute
          compile $ do
            let feedCtx = postCtx `mappend` bodyField "description"
            posts <- fmap (take 10) . recentFirst =<< loadAllSnapshots "posts/**" "post-content"
            render' feedConfiguration feedCtx posts

    rss "rss.xml" renderRss
    rss "atom.xml" renderAtom

feedConfiguration ::
  FeedConfiguration
feedConfiguration =
  FeedConfiguration {
      feedTitle       = "The Gap Chess Club"
    , feedDescription = ""
    , feedAuthorName  = "TGCC"
    , feedAuthorEmail = "contact@thegapchessclub.org.au"
    , feedRoot        = "https://thegapchessclub.org.au/"
    }
