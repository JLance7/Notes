const express = require('express')
const router = express.Router()
const model = require('../model')

router.get('/get-items', async (req, res) => {
  try {
    const items = await model.find().sort({timestamp: "desc"})
    res.send(items)
  } catch (e) {
    console.log(e)
  }
})

router.delete('/remove-item/:id', async (req, res) => {
  try {
    console.log(req.params.id)
    const item = await model.findByIdAndDelete(req.params.id)
    res.send({response: 'done'})
  } catch (error) {
    console.log(error)
  }
})

router.post('/add-item', async (req, res) => {
  try{
    console.log(req.body)
    const item = new model({
      item: req.body.item,
      date: req.body.date
    })
    await item.save()

    res.send({'response': 'done'})
  } catch (e){
    console.log(e)
  }
})

module.exports = router