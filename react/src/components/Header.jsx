const Header = () => {
  return (
    <div style={styles.wrapper}>
      <div style={styles.innerWrapper}>
        <p style={styles.title}>Todo App</p>
      </div>
    </div>
  )
}

const styles = {
  wrapper: {
    backgroundColor: '#845ef7',
    fontSize: '40px',
    color: 'white',
    
  },
  innerWrapper: {
    
    marginTop: 0,
    marginBottom: 0,
    marginLeft: 'auto',
    marginRight: 'auto',
    width: '60%',
  },
  title: {
    display: 'inline-block',
    marginTop: 10,
    marginBottom: 10,
    marginLeft: 20
    // borderBottom: 4,
    // borderBottomColor: 'black',
    
  }
}

export default Header