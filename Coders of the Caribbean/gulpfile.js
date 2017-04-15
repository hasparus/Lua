'use strict';

const gulp = require('gulp');
const concat = require('gulp-concat');
const removeLines = require('gulp-remove-lines');

const luafiles = [
  './src/lib/object/object.lua',
  './src/lib/vector2/vector2.lua',
  './src/pirates/*.lua',
  './src/pirates/agent/agent.lua'
];

gulp.task('concat-lua', function() {
  return gulp.src(luafiles)
    .pipe(concat({ path: 'joint.lua' }))
    .pipe(removeLines({ filters: [/(require.*)+/] }))
    .pipe(gulp.dest('./'));
});

gulp.task('watch', () => {
  gulp.watch(luafiles, ['concat-lua']);
});
