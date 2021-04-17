function call (method, url, data){
    console.log("call result", method, url, data)
    var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function() {
        console.log("call result", this)
        if (this.readyState == 4 && this.status == 200) {
            // document.getElementById("feedback").innerHTML = this.responseText;
        }
    };

    xhttp.open(method, url, true);
    xhttp.setRequestHeader("Content-type", "text/json");
    xhttp.send(JSON.stringify(data));
}


function handleLogin(){
    let data = {}
    data.email = document.getElementById("email").value
    data.password = document.getElementById("password").value

    call("POST", "http://localhost/jsonbin", data)
}

function handleConnect(id, withWho){
    let data = {id:id, with:withWho}

    call("POST", "http://localhost/jsonbin", data)
}

function handlePost(){
    let data = {}
    data.title = document.getElementById("title").value
    data.content = document.getElementById("content").value
    data.file = document.getElementById("file").files[0]
    
    const reader = new FileReader();
    reader.addEventListener("load", () => {
        // convert image file to base64 string
        data.upload = reader.result

        call("POST", "http://localhost/jsonbin", data)
    }, false);

    reader.readAsDataURL(data.file)

}
