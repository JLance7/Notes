import '../styles/styles.css';
import Todo from './Todo';

const App = ({showTodo}) => {
  return (
    <div className={showTodo ? 'App' : 'hidden'}>
      <Todo />
    </div>
  );
}


export default App


