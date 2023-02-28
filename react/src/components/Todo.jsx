import '../styles/styles.css'
import { useEffect, useState } from 'react'
import { FaTrash } from 'react-icons/fa'

const Todo = () => {
  const [items, setItems] = useState([])
  const [todoText, setTodoText] = useState('')
  const [error, setError] = useState(false)

  useEffect(() => {
    initialCall()
  }, [])

  const initialCall = async () => {
    try {
      let posts = await fetch('http://localhost:2000/get-items')
      posts = await posts.json()
      posts = posts.reverse()
      console.log(posts)
      setItems(posts)
    } catch (error) {
      console.log(error)
    }
  }

  const MyItems = items.map((item) => {
    return (
      <div key={item._id}>
        <p style={{
          fontSize: 12, marginLeft: 20, marginBottom: -10
        }}>{item.date}</p>
        <div className='item-block' >
          <input onChange={async () => await removeItem(item._id)}type='checkbox' style={{
            marginLeft: '20px'}}/>
          <p style={{
            display: 'inline-block',
            alignSelf: 'center',
            marginLeft: '40px'
          }}>{item.item}</p>
          <a style={{
            display: 'inline-block', marginLeft: 'auto', alignSelf: 'center'
          }}onClick={async () => {
            console.log('Click!')
            await removeItem(item._id)}}>
            <FaTrash style={{
              color: 'red',
              alignSelf: 'center',
              marginLeft: 'auto',
              marginRight: '10px'
            }}/>
          </a>
        </div>
      </div>
    )
  })

  async function addItem() {
    try{
      if (todoText != ''){
        setError(false)
  
        const payload = {
          item: todoText,
          date: new Date().toLocaleString().split(',')[0],
          timestamp: new Date().toLocaleString()
        }

        const response = await fetch('http://localhost:2000/add-item', {
          method: "POST",
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(payload)
        });
        
        setTodoText('')
      }
      else {
        setError(true)
        setTimeout(() => setError(false), 2000)
      }
    } catch (e){ console.log(e)}
    
  }

  async function removeItem(id){
    console.log('nice')
    try {
      setTimeout(async () => {
        console.log('id: ', id)
        const response = await fetch(`http://localhost:2000/remove-item/${id}`, {
          method: 'delete',
          headers: {
            'Content-Type': 'application/json'
          }
        })
        console.log(response)
        initialCall();
      }, 1000)
      
    } catch (error) {
      console.log('HERE')
      console.log(error)
    }
  }

  return (
    <div className='block-div'>
      {error && <p style={{color: 'red', position: 'absolute', top: '2'}}>You did not enter any text</p>}
      <div className='todo-top'>
        <input type='text' className='input' value={todoText || ''} placeholder='New Item' onChange={async event => {
          setTodoText(event.target.value)}}/>
        <button className='button' onClick={async () => {
          await addItem()
          await initialCall()
        }}>Add Item</button>
      </div>
      {MyItems}
    </div>
  )
}




export default Todo