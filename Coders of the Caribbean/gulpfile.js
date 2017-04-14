'use strict';

const gulp = require('gulp');
const concat = require("gulp-concat");
 
const luafiles = [
        './agent.lua',
        './exec.lua'
      ];

gulp.task('concat-lua', function() {
  return gulp.src(luafiles)
    .pipe(concat({ path: 'main.lua' }))
    .pipe(gulp.dest('./'));
});

gulp.task('watch', () => {
  gulp.watch(luafiles, ['concat-lua']);
});
