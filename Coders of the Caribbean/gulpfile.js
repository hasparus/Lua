'use strict';

const gulp = require('gulp');
const concat = require("gulp-concat");
 
const luafiles = [
        './src/agent.lua',
        './src/exec.lua'
      ];

gulp.task('concat-lua', function() {
  return gulp.src(luafiles)
    .pipe(concat({ path: 'joint.lua' }))
    .pipe(gulp.dest('./'));
});

gulp.task('watch', () => {
  gulp.watch(luafiles, ['concat-lua']);
});
