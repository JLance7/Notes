import React from 'react';
import ReactDOM from 'react-dom/client';
import reportWebVitals from './helper/reportWebVitals';
//styles
import './styles/styles.css'
//components
import App from './components/App';
import Header from './components/Header'
import Footer from './components/Footer'
import { useState } from 'react';

const root = ReactDOM.createRoot(document.getElementById('root'));



const Body = (link) => {
  const [showTodo, setShowTodo] = useState(true)

  return (
    <div className='main-wrapper'>
      <div className='info'>
        <div className='info-block'>
          <p className='link-title'>Quick Links</p>
          <ul>
            <li><a onClick={() => setShowTodo(true)} href='#'>Todo App</a></li>
            <li><a onClick={() => setShowTodo(false)} href='#'>About</a></li>
          </ul>
        </div>  
      </div>

      <App showTodo={showTodo} />
      <div className={showTodo ? 'hidden': 'unhidden todo'}>
        <p style={{
          marginTop: '40px',
          fontSize: '30px'
        }}>
          Tools used:
        </p>
        <ul style={{
          listStyeType: 'disc'
        }} className='about-ul'>
          <li>React UI</li>
          <li>Express.js Server & mongodb</li>
          <li>Mongodb & mongo-express docker images for development, react & server build docker images for deployment</li>
          <li>Jenkins pipeline</li>
          <li>Terraform for aws infrastructure as code</li>
        </ul>
      </div>

      <div></div>
    </div>
  )
}

root.render(
  <React.StrictMode>
    <div style={{
      position: 'relative',
      backgroundColor: '#F0F8FF'
    }}>
      <Header />
      <Body />
      <Footer />
    </div>
  </React.StrictMode>
);

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
// reportWebVitals();
