# ghost + buster

From http://www.jackpearce.com/post/88675794392/have-a-lightning-fast-blog-and-host-it-for-free

## Start Ghost
```
cd ghost
npm start
```

## Edit your blog

Write post in your browser [locally](http://localhost:2368/ghost).

```
open http://localhost:2368/ghost
```

Publish your articles.

## Publish to GitHub Pages

Genarate static pages, [preview them](http://localhost:9000), push them to GitHub Pages.

```
buster generate --domain=http://localhost:2368
buster preview
open http://localhost:9000
buster deploy
```

View results on [GitHub Pages](http://stefanscherer.github.io).


