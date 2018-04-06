This is The Gap Chess Club blog.

You can build the contents of the blog locally with: 
```
nix-build release.nix -A blog
```
where the output will be in `result/blog`

You can build the site generator with:
```
nix-build release.nix -A generator
```
where the output will be the executable  `result/site`

You can use that to bring up a local preview server with:
```
cd content
../result/bin/site watch
```
and the content will be served from http://localhost:8000/
