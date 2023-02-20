//tsc --watch
//node index.js

let id: number =  5;

id = 2;
console.log(id)

let company: string = 'hi'
let isPublished: boolean = true
let x: any = 'Hello'
x = true
let age: number
age = 30

let ids: number[] = []
ids.push(1)
let arr: any[] = [1, true, 'hi']

//tuple
let person: [number, string, boolean] = [1, 'brad', true]
//tuple array
let employee: [number, string][] 
employee = [
  [1, 'josh'],
  [2, 'mike']
]

//union
let pid: string | number = 22;

//enum
enum Direction1 {
  Up,
  Down,
  Left,
  Right
}

let val = 0
if (val == Direction1.Up){ console.log('yes')} else console.log('no')

//objects
const user: {
  id: number,
  name: string
} = {
  id: 1,
  name: 'hi'
}

type User = {
  id: number,
  name: string
}

const user2: User = {
  id: 1,
  name: 'hi'
}

//type asserition
let cid: any = 1;
let customerId = <number>cid
//let customerId = cid as number

//functions
function addNum(x: number, y: number): number{
  return x + y
}

//interfaces
interface UserInterface {
  readonly id: number
  name: string
  age?: number //optional
}

const user3: UserInterface = {
  id: 1,
  name: 'hi'
}

type Point = number | string //can't use interface here
const P1: Point = 1

// user3.id = 5

interface MathFunc {
  (x: number, y: number): number
}

const add: MathFunc = (x: number, y: number): number => x + y


interface PersonInterface {
  id: number
  name: string
  register(): string
}

//classes
class Person implements PersonInterface {
  public id: number
  name: string

  constructor(id: number, name: string) {
    this.id = id
    this.name = name
    console.log('here')
  }

  register(){
    return `${this.name} is now registered`
  }
}

const josh = new Person(1, 'josh')
josh.id = 2
josh.register()

class Emplyee extends Person {
  position: string
  constructor(position: string, name: string, id: number){
    super(id, name)
    this.position = position
  }
}

const emp = new Emplyee('dev', 'josh', 3)
console.log(emp.register())

//generics
function getArray<T>(items: T[]): T[] {
  return new Array().concat(items)
}

let numArray = getArray<number>([1, 2, 3, 4])
let strArray = getArray<string>(['hi', 'ho', 'he', 'him'])
// numArray.push('hello')
