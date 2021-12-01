var gulp = require('gulp');
var minifycss = require('gulp-clean-css');
var terser = require('gulp-terser');
var htmlmin = require('gulp-html-minifier-terser');
var htmlclean = require('gulp-htmlclean');

// 压缩 public 目录 css
gulp.task('minify-css', function () {
    return gulp.src('./public/**/*.css')
        .pipe(minifycss())
        .pipe(gulp.dest('./public'));
});
// 压缩 public 目录 html
gulp.task('minify-html', function () {
    return gulp.src('./public/**/*.html')
        .pipe(htmlclean())
        .pipe(htmlmin({
            removeComments: true,
            removeEmptyAttributes: true,
            removeRedundantAttributes: true,
            collapseWhitespace: true,
            minifyJS: true,
            minifyCSS: true,
            minifyURLs: true,
        }))
        .pipe(gulp.dest('./public'))
});
// 压缩 public/js 目录 js
gulp.task('minify-js', function () {
    return gulp.src('./public/**/*.js')
        .pipe(terser())
        .pipe(gulp.dest('./public'));
});
// 执行 gulp 命令时执行的任务
gulp.task('default', gulp.series(
    'minify-html', 'minify-css', 'minify-js'
));