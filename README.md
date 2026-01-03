# smol_build.sh
Very basic html templating system as a small bash script

## What it does

Using this system is very simple, there are just a few things to understand.

Put simply: As we descend deeper into the directories, the pages will inherit more layers of templating

- This is a build system for static content only
- Once built, the directory structure will remain the same
- `smol_template.html` files will not appear in the build
- Once built, all normal `.html` files content will appear in build path, but wrapped in a template.
- The `<smol_content/>` tag is replaced by content deeper in the directory tree (first by more templates, and eventually by the normal `html` files.
- All other type of files are copied to their place build directory

## Usage

The command takes two arguments, a path to the root of the project directory, and a path to the root of the build directory.
If the build directory does not exist, it will create it, it will also delete all content in the build directory so BE CAREFUL.

e.g. `./smol_build.sh site build`

You can try building the included example by running `./smol_build.sh example build`, and you can run a quick web server with `python -m http.server 8000 -d build`.

## Quick Example

**For a file structure like this:**

```
 - /site/
 	- index.html
 	- smol_template.html
 	- /blog/
 		- smol_template.html
 		- index.html
 		- post_1.html
```

**...where the files are as follows:**

*/site/smol_template.html*
```html
<html>
	<h1>Site Title</h1>
	<smol_content/>
</html>
```

*/site/index.html*
```html
<p> Welcome to my home page!</p>
```

*/site/blog/smol_template.html*
```html
<h2>Here is my blog</h2>
<smol_content/>
```

*/site/blog/index.html*
```html
<h3>Posts:</h3>
<ul>
	<li> <a href="/blog/post1.html"> Post 1 </a> <li>
</ul>
```

*/site/blog/post_1.html*
```html
<h3>Post #1</h3>
<p> Wow isn't this an interesting post!!!</p>
```

**...the command `./smol_build.sh site build` would build the following:**

*/build/index.html*
```html
<html>
	<h1>Site Title</h1>
	<p> Welcome to my home page!</p>
</html>
```

*/build/blog/index.html*
```html
<html>
	<h1>Site Title</h1>
	<h2>Here is my blog</h2>
	<h3>Posts:</h3>
	<ul>
		<li> <a href="/blog/post1.html"> Post 1 </a> <li>
	</ul>
</html>
```

*/build/blog/post_1.html*
```html
<html>
	<h1>Site Title</h1>
	<h2>Here is my blog</h2>
	<h3>Post #1</h3>
	<p> Wow isn't this an interesting post!!!</p>
</html>
```
