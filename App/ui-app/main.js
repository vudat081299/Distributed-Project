let btnCorrect = document.getElementById('btn-correct')
let btnWrong = document.getElementById('btn-wrond')
let btnEle = document.getElementsByTagName('button')

let temp = render()

for (let btn of btnEle) {
  btn.addEventListener('click', () => {
    userAnswerHandler(temp)
    temp = render()
  })
}

// btnEle.forEach((btn) => {
//     btn.addEventListener('click', () => {
//         userAnswerHandler(temp)
//         temp = render()
//       })
// })
