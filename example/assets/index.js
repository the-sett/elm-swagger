require('../assets/styles/roboto.css')
require('../assets/images/data_center-large.png')

const {
  Elm
} = require('../src/elm/Top.elm');

const app = Elm.Top.init({
  node: document.getElementById('application')
});
