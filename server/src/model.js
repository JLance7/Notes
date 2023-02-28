const mongoose = require('mongoose')

const mongooseSchema = {
  item: {
    type: String,
    required: true
  },
  date: {
    type: String,
    required: true
  }
}

module.exports = mongoose.model('my-model', mongooseSchema, 'items')