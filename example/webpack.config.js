const path = require('path');
const webpack = require('webpack');
const merge = require('webpack-merge');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const ExtractTextPlugin = require('extract-text-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin')
const UglifyJsPlugin = require('uglifyjs-webpack-plugin')
const CompressionPlugin = require("compression-webpack-plugin")

const prod = 'production';
const dev = 'development';

// build env
const TARGET_ENV = process.env.npm_lifecycle_event === 'build' ? prod : dev;
const isDev = TARGET_ENV === dev;
const isProd = TARGET_ENV === prod;


// entry and output path/filename variables
const entryPath = path.join(__dirname, 'assets/index.js');
const outputPath = path.join(__dirname, 'dist');
const outputFilename = isProd ? '[name]-[hash].js' : '[name].js';

console.log(`Building for ${TARGET_ENV}`);

const commonConfig = {
  output: {
    path: outputPath,
    filename: `assets/${outputFilename}`,
  },

  resolve: {
    extensions: ['.js', '.elm'],
  },

  module: {
    noParse: /\.elm$/,
    rules: [{
        test: /\.(css)$/,
        use: [{
          loader: 'file-loader',
          options: {
            name: 'styles/[name].[ext]'
          }
        }]
      },
      {
        test: /\.(png|jpg|gif)$/,
        use: [{
          loader: 'file-loader',
          options: {
            name: 'images/[name].[ext]'
          }
        }]
      }
    ]
  },

  plugins: [
    new HtmlWebpackPlugin({
      template: 'assets/index.html',
      inject: 'body',
      filename: 'index.html',
    }),
  ]
};

if (isDev) {
  module.exports = merge(commonConfig, {
    mode: 'development',

    entry: [
      'webpack-dev-server/client?http://localhost:9071',
      entryPath,
    ],

    module: {
      rules: [{
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: [{
            loader: 'elm-hot-webpack-loader'
          },
          {
            loader: 'elm-webpack-loader',
            options: {
              verbose: true,
              debug: false
            }
          }
        ]
      }]
    },

    devServer: {
      historyApiFallback: true,
      contentBase: './src',
      inline: true,
      stats: 'errors-only',
      port: 9071,
      disableHostCheck: true
    }
  });
}

if (isProd) {
  module.exports = merge(commonConfig, {
    mode: 'production',

    entry: entryPath,

    module: {
      rules: [{
          test: /\.elm$/,
          exclude: [/elm-stuff/, /node_modules/],
          use: 'elm-webpack-loader'
        },
        {
          test: /\.s?css$/,
          use: ExtractTextPlugin.extract({
            fallback: 'style-loader',
            use: ['css-loader', 'postcss-loader', 'sass-loader']
          })
        }
      ]
    },

    plugins: [
      new ExtractTextPlugin({
        filename: 'static/css/[name]-[hash].css',
        allChunks: true
      }),

      new CopyWebpackPlugin([{
          from: 'src/static/img',
          to: 'static/img'
        },
        {
          from: 'src/static/favicon.ico'
        }
      ]),

      new UglifyJsPlugin(),

      new CompressionPlugin(),
    ]
  });
}
