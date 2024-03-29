/************************************************************************
 * Beverage Form Data Handlers
 ************************************************************************/
// Load initial beverage data
getBeverages();

// Configure listeners for the main form 
let addForm = document.getElementById("add");
let roomList = document.getElementById("dataDetails");

addForm.addEventListener("submit", getData);
addForm.addEventListener("formdata", formUpdate);

/**
 * Event listener handler to populate a new FormData instance.
 * @param {Object} e 
 */
function getData(e) {
    e.preventDefault();
    new FormData(addForm);
}

/**
 * Helper to get all available beverages.
 */
function getBeverages() {
    const xhr = new XMLHttpRequest();
    // Handle success from API
    xhr.addEventListener("load", event => {
        let response = JSON.parse(event.target.responseText);
        if (response.data) {
            createTable(response.data);
        }

        if (response.message) {
            updateMessage(event.target.status, response.message);
        }
    });

    // Handle error from API
    xhr.addEventListener("error", event => {
        console.log(event);
    });

    // Send GET request to server
    xhr.open("GET", "/getBeverages", true);
    xhr.send();
}

/**
 * Helper function to populate the form with the data from the row
 * being edited. Only one row can be edited at a time. 
 * Drags user view up to the form. 
 * 
 * @param {Object} item 
 */
function editRow(item) {
    resetForm();
    clearMessage();
    document.getElementById("id").value = item.beverageID;
    document.getElementById("name").value = item.name;
    document.getElementById("description").value = item.description;
    document.getElementById("type").value = item.type;
    document.getElementById("price").value = item.price;

    // Check boxes for the ingredients in the drink
    item.ingredients.forEach(ingredient => {
        document.getElementById(ingredient).checked = true;
    });

    document.getElementById("beverageForm").scrollIntoView({
        behavior: 'smooth',
        block: 'center'
    });
};

/**
 * Helper function to submit new beverage data.
 * 
 * @param {Object} e 
 */
function formUpdate(e) {
    //resetForm();
    clearMessage();

    let data = {};
    e.formData.forEach((value, key) => {
        data[key] = value
    });

    data.ingredients = e.formData.getAll('ingredients');

    const xhr = new XMLHttpRequest();
    // Handle success from API
    xhr.addEventListener("load", event => {
        let response = JSON.parse(event.target.responseText);

        if (response.message) {
            updateMessage(event.target.status, response.message);
        }

        document.getElementById("message").scrollIntoView({
            behavior: 'smooth',
            block: 'center'
        });

        if(event.target.status == 200) {
            getBeverages();
        }
    });

    // Handle error from API
    xhr.addEventListener("error", event => {
        console.log(event);
    });

    // Send POST request to server
    if (data.id && data.id > 0) {
        xhr.open("POST", "/updateBeverage", true);
      } else {
        xhr.open("POST", "/addBeverage", true);
    }

    xhr.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
    xhr.send(JSON.stringify(data));
};

/**
 * Helper function to make a delete request to the database and then 
 * remove the row from the view upon successful deletion. 
 * 
 * @param {Object} item 
 */
function deleteBeverage(item) {
    clearMessage();
    const xhr = new XMLHttpRequest();
    // Handle success from API
    xhr.addEventListener("load", event => {
        let response = JSON.parse(event.target.responseText);
        if (response.message) {
            updateMessage(event.target.status, response.message);
        }
        document.getElementById("message").scrollIntoView({ behavior: 'smooth', block: 'center' });

        if (event.target.status == 200) {
            getBeverages();
        }
    });

    // Handle error from API
    xhr.addEventListener("error", event => {
        console.log(event);
    });

    // Send POST request to server
    xhr.open("POST", "/deleteBeverage", true);
    xhr.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
    xhr.send(JSON.stringify(item));
};

/**
 * Helper function to reset values in the form. 
*/
function resetForm() {
    document.getElementById("id").value = -1;
    document.getElementById("name").value = "";
    document.getElementById("description").value = "";
    document.getElementById("price").value = 0;
    document.getElementById("type").value = "";
    uncheckAll();
};

/**
 * Helper to uncheck all boxes in the form.
 */
function uncheckAll() {
    let ingredients = document.getElementsByName("ingredients");

    ingredients.forEach(ingredient => {
        ingredient.checked = false;
    });
};