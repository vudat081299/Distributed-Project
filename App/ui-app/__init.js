const OPERATION = ['+', '-']
let score = 0

function render() {
  let expressionEle = document.getElementById('expression')
  let quizAnswerEle = document.getElementById('quiz-answer')
  let scoreEle = document.getElementById('score')
  let firstNum = Math.round(Math.random() * 9)
  let secondNum = Math.round(Math.random() * 9)
  let oper = OPERATION[Math.round(Math.random() * (OPERATION.length - 1))]
  let temp = Math.round(Math.random())

  let expression = `${firstNum} ${oper} ${secondNum}`
  let quizAnswer = `= ${getQuizAnswer(firstNum, secondNum, oper, temp)}`

  expressionEle.innerText = expression
  quizAnswerEle.innerText = quizAnswer
  scoreEle.innerText = score

  return temp
}

function getQuizAnswer(x, y, oper, temp) {
  switch (temp) {
    case 1:
      return getResult(x, y, oper)
    case 0:
      let temp2 = Math.random()
      if (temp2 <= 0.5) {
        return getResult(x, y, oper) + 1
      } else {
        return getResult(x, y, oper) - 1
      }
  }
}

function getResult(x, y, oper) {
  switch (oper) {
    case '+':
      return x + y
    case '-':
      return x - y
  }
}

function userAnswerHandler(temp) {
  if (event.target.id == 'btn-correct') {
    switch (temp) {
      case 1:
        score += 1
    }
  } else if (event.target.id == 'btn-wrong') {
    switch (temp) {
      case 0:
        score += 1
    }
  }
}
