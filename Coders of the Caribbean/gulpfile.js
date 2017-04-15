'use strict';

const gulp = require('gulp');
const concat = require("gulp-concat");
 
const luafiles = [
  './src/lib/object/object.lua',
  './src/lib/vector2/vector2.lua',
  './src/pirates/*.lua'
];

gulp.task('concat-lua', function() {
  return gulp.src(luafiles)
    .pipe(concat({ path: 'joint.lua' }))
    .pipe(gulp.dest('./'));
});

gulp.task('watch', () => {
  gulp.watch(luafiles, ['concat-lua']);
});
