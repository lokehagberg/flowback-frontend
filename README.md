# Setting up the project

This project requires [node and npm](https://nodejs.org) and
currently supports node version v22.9.0.

To run the frontend you will need to set up both the [frontend](#set-up-the-frontend) and the [backend](#set-up-the-backend).


## Set up the frontend
```bash
# Downloading the files
git clone https://github.com/lokehagberg/flowback-frontend.git

#Then you install the dependencies
cd flowback-frontend
npm install
```

### Environment variables
To get started, copy the `.env.dev.example` file and rename it to `.env` and adjust the values as needed.

| Variable | Description |
|----------|-------------|
| `PUBLIC_API_URL` | URL of the backend API (e.g., `http://127.0.0.1:8000`) |
| `VITE_WEBSOCKET_API` | WebSocket API URL (e.g., `http://127.0.0.1:8000`) |
| `PUBLIC_MODE` | Set to `DEV` or `PROD` to determine environment mode |
| `PUBLIC_DISABLE_GROUP_CREATION` | Set to `TRUE` to disable group creation button display (must also be disabled in backend) |
| `PUBLIC_LOGO` | Logo to use, either `DEFAULT` or `REFORUM` |
| `PUBLIC_HAS_API` | Set to `TRUE` if API requests should have `/api/` at the start |
| `PUBLIC_IMAGE_HAS_API` | Set to `TRUE` if image URLs should include `/api/` (try enabling if images aren't displaying) |
| `PUBLIC_ONE_GROUP_FLOWBACK` | Set to `TRUE` if the Flowback instance will only have one group |
| `PUBLIC_SUPPORT_MAIL` | Email address for technical support |
| `PUBLIC_SUPPORT_PHONE` | Phone number for technical support |
| `PUBLIC_FLOWBACK_AI_MODULE` | Set to `TRUE` to enable the optional AI module |
| `PUBLIC_FLOWBACK_LEDGER_MODULE` | Set to `TRUE` to enable the optional ledger module |
| `PUBLIC_WEBSOCKET_API` | WebSocket API URL (e.g., `ws://127.0.0.1:8000`) |

Then the .env.example file will give you the information needed to connect it to a backend instance of flowback. Once that is done you can run it

### Building
```bash
npm run build
```

### Running the project
```bash
npm run dev
```
Or start the server and open the app in a new browser tab
```bash
npm run dev --open
```

### Preview production
You can preview the production build with `npm run preview`.

> To deploy your app, you may need to install an [adapter](https://kit.svelte.dev/docs/adapters) for your target environment.

## Set up the backend
To set up the backend you will need to download the backend repository and follow the installation example for docker compose listed in the readme. The backend can be found at [https://github.com/lokehagberg/flowback-backend](https://github.com/lokehagberg/flowback-backend).

To create an admin account that can be used in the frontend you will need to navigate to the terminal in the docker container called "flowback-backend-1" and execute the following command:
```python
python manage.py createsuperuser
```

Now you are ready to login, navigate to `localhost:4000/login` and login with the created admin user.

# Documentation for developers:

## Flowback Specific

If you're experienced with React, Vue e.t.c and new to svelte you can check out this amazing tutorial by the svelte developers:
https://svelte.dev/tutorial/basics


Remember to check the "Generic" folder before doing something that's very common.


Check out the backend documentation here: https://digitaldemocracy.flowback.org/api/schema/redoc/

## Generally good code practices:
```js
// Unnecessary nesting
if (boolean) {
    // long statement...
}


// Better practice:
if (!boolean) return;
// long statement...


// Inside a for loop, use continue
for (let i = 0; i < array.length; i++) {
    if (!boolean) continue;
    // long statement...
}


// Rarely use a timer, set up async to wait for the thing you want to change to have changed.
//TODO add example


// Smaller functions that do one task is almost always better
const doMassiveNumberOfJobs = () => {
    // Logic for entering a car
    // Logic for driving a car to a location
    // Logic for parking a car
};


//Better for readability and understanding
const carCutsceneGood = (car, subject) => {
    enterCar(car, subject);
    driveCarTo();
    parkCar();
};


// there should be no side effects
const enterCar = (car, subject) => {
    //This is acceptable
    subject.changePosition(car.seat.position);


    //This is not, since the variable is not an input to enterCar.
    //Exception to this rule in reactive-state front end development such as svelte and react. 
    camera.choices("carCamera");
    saveFile.write("is in car!");
};


//Better:
const carCutsceneBetter = (car, subject, camera, saveFile) => {
    enterCarBetter(car, subject, camera, saveFile);
    driveCarTo();
    parkCar();
};


const enterCarBetter = (car, subject, camera, saveFile) => {
    subject.changePosition(car.seat.position);
    camera.choices("carCamera");
    saveFile.write("is in car!");
};


/*
    Mostly Flat Hierarchy. Less (invisible) nesting, better maintainability,
    easier to debug since problems can be seen when variables go from different functions
    of different levels of abstraction more easily.


    Things of equal hierarchy level should roughly be on the same level of abstraction
*/


// Bad:


const mainBad = () => {
    thingtoDo1(thing);
};


const thingtoDo1 = (thing) => {
    thing *= 2;
    thingToDo2(thing);
};


const thingtoDo2 = (thing) => {
    thing += 1;
    thingToDo3(thing);
};


// Good:


const mainGood = () => {
    thing = 5;
    thing = thingtoDo1(thing);
    thing = thingtoDo2(thing);
    thing = thingtoDo3(thing);
};


const thingtoDo1Good = (thing) => {
    return (thing *= 2);
};


const thingtoDo2Good = (thing) => {
    return (thing += 1);
};


// Avoid Global variables as much as possible except for one's that are used all over the place such as for example the translation function


//Good
<div>{T("Text to be translated")}</div>


//Files should generally not be longer than 250 lines long, maybe pushing up to 300 in some cases. Functions should generally fit one screen. 


//Have paragraphs in functions to differentiate different operations
```
# Docker
To easily run the frontend everywhere we use docker to containerize the application. To run the container, you must have docker installed. Docker setup inspired from [self-hosted-sveltekit-demo](https://github.com/khromov/self-hosted-sveltekit-demo/tree/main)

## Install docker
It is recommended to install docker desktop.

[Install on Mac](https://docs.docker.com/desktop/install/mac-install/)

[Install on Windows](https://docs.docker.com/desktop/install/windows-install/)

[Install on Linux](https://docs.docker.com/desktop/install/linux-install/)

## Set up .env
Make sure you have updated your `.env` file to include the necessary variables.
Currently only variables that are imported dynamically work. [See more.](https://joyofcode.xyz/sveltekit-environment-variables#dynamic-for-variables-during-runtime)

To get started, copy the `.env.dev.example` file and rename it to `.env` and adjust the values as needed. For more info about the `.env` values, [see the environment variable section.](#environment-variables)


## How to build the docker container:
Go to the root of the project.

1. Build the container:
```bash
docker compose build
```
Only build the container if changes have been made in the application code or Dockerfile.


2. Launch the container:
```bash
docker compose up -d
```

## How to manually build the docker image (not required)
Make sure you're at the root of the project.
```bash
docker build -t flowback-frontend .
```

## Want to update the docker compose file?
You can find `docker-compose.yaml` in the root of the project.

### Further reading
https://www.youtube.com/watch?v=NLjolI9FwCU
