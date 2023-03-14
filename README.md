## Downloading the project

```bash
# Downloading the files
git clone https://github.com/lokehagberg/flowback-frontend.git
```

Once you've created a project and installed dependencies with `npm install` (or `pnpm install` or `yarn`), start a development server:
```bash
npm install
```

Then the .env.example file will give you the information needed to connect it to a backend instance of flowback. Once that is done you can run it

## Running the project
```bash
npm run dev

# or start the server and open the app in a new browser tab
npm run dev -- --open
```

## Building

To create a production version of your app:

```bash
npm run build
```

You can preview the production build with `npm run preview`.

> To deploy your app, you may need to install an [adapter](https://kit.svelte.dev/docs/adapters) for your target environment.


# Documentation for developers:

## Flowback Specific

If you're experienced with React, Vue e.t.c and new to svelte you can check out this amazing tutorial by the svelte developers:
https://svelte.dev/tutorial/basics


Remember to check the “Generic” folder before doing something that’s very common.


Check out the backend documentation here: https://docs.flowback.org/

## Generally good code practices:
```{js}
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


// Avoid Global variables as much as possible except for one’s that are used all over the place such as for example the translation function


//Good
<div>{T("Text to be translated")}</div>


//Files should generally not be longer than 250 lines long, maybe pushing up to 300 in some cases. Functions should generally fit one screen. 


//Have paragraphs in functions to differentiate different operations
```
