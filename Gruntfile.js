module.exports = function (grunt) {
    'use strict';

    grunt.initConfig({
        concat: {
            coffee: {
                src: [
                    "scripts/models/track.coffee",
                    "scripts/models/tracks.coffee",
                    "scripts/models/timeline.coffee",
                    "scripts/views/*.coffee",
                    "scripts/app.coffee",
                ],
                dest: 'temp/videoEditor.coffee'
            },
            css: {
                src: [
                    "stylesheets/pure.css",
                    "temp/all.css"
                ],
                dest: 'temp/styles.css'
            }
        },
        coffee: {
            compile: {
                files: {
                    'temp/videoEditor.js': 'temp/videoEditor.coffee'
                }
            }
        },
        uglify: {
            build: {
                files: {
                    'scripts.min.js': ['vendor/exoskeleton/exoskeleton.js', 'temp/videoEditor.js']
                }
            }
        },
        cssmin: {
            minify: {
                src: ['temp/styles.css'],
                dest: 'styles.min.css'
            }
        },
        less: {
            "temp/all.css": 'stylesheets/*.less',
            options: {
                compress: true
            }
        },
        clean: {
            build: {
                src: ["temp"]
            }
        }
    });

    grunt.loadNpmTasks('grunt-contrib-jshint');
    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.loadNpmTasks('grunt-contrib-concat');
    grunt.loadNpmTasks('grunt-contrib-uglify');
    grunt.loadNpmTasks('grunt-contrib-less');
    grunt.loadNpmTasks('grunt-contrib-cssmin');
    grunt.loadNpmTasks('grunt-contrib-clean');


    grunt.registerTask('default',['less', 'concat',  'coffee', 'cssmin', 'uglify', 'clean']);
//    grunt.registerTask('default', ['coffee', 'concat', 'uglify', 'hash', 'clean']);
};