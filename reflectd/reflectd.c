/*
 * Program to display the input status of a GPIO.
 * Board used : OrangePi Zero 2w
 * Prerequisites : 
 *   - WiringOP, http://www.orangepi.org/orangepiwiki/index.php/Orange_Pi_Zero_2W#How_to_install_wiringOP
 */

#include <stdio.h>
#include <stdlib.h>

#include <unistd.h>
#include <sys/types.h>

#include <wiringPi.h>


#define BUTTONS_POWER_PIN    24
#define STOP_BUTTON_PIN      26
#define START_BUTTON_PIN     27

#define DEBOUNCE_DELAY       50

int startButtonState = 0;
int lastStartButtonState = 0;
unsigned long startBtnLastDebounceTime = 0;

int stopButtonState = 0;
int lastStopButtonState = 0;
unsigned long stopBtnLastDebounceTime = 0;


void setup()
{
    pinMode(BUTTONS_POWER_PIN, OUTPUT);
    pinMode(START_BUTTON_PIN, INPUT);
    pinMode(STOP_BUTTON_PIN, INPUT);

    digitalWrite(BUTTONS_POWER_PIN, HIGH);

    stopButtonState = digitalRead(STOP_BUTTON_PIN);
    startButtonState = digitalRead(START_BUTTON_PIN);
}

void stopHeadupDisplay()
{
    system("/opt/reflect/stop &");
}

void startHeadupDisplay()
{
    system("/opt/reflect/start &");
}

void checkStartButton()
{
    int startBtnValue = digitalRead(START_BUTTON_PIN);

    if (startBtnValue != lastStartButtonState) {
        startBtnLastDebounceTime = millis();  // Reset debounce timer
    }

    if ((millis() - startBtnLastDebounceTime) > DEBOUNCE_DELAY) {
        if (startBtnValue != startButtonState)
        {
            startButtonState = startBtnValue;

            if (startButtonState == HIGH) {
                printf("START button pressed\n");
                startHeadupDisplay();
            }
        }
    }

    lastStartButtonState = startBtnValue;
}

void checkStopButton()
{
    int stopBtnValue = digitalRead(STOP_BUTTON_PIN);

    if (stopBtnValue != lastStopButtonState) {
        stopBtnLastDebounceTime = millis();  // Reset debounce timer
    }

    if ((millis() - stopBtnLastDebounceTime) > DEBOUNCE_DELAY) {
        if (stopBtnValue != stopButtonState)
        {
            stopButtonState = stopBtnValue;

            if (stopButtonState == HIGH) {
                printf("STOP button pressed\n");
                stopHeadupDisplay();
            }
        }
    }

    lastStopButtonState = stopBtnValue;
}

void loop()
{
    checkStartButton();
    checkStopButton();
}

int main()
{
    printf("~~~ GPIO pin status ~~~\n");

    if (geteuid() != 0)
    {
        fprintf(stderr, "\n Error: Program should be run as root.\n");
        exit(3);
    }

    if (wiringPiSetup() == -1) {
        printf("WiringPi setup failed!\n");
        exit(2);
    }

    setup();

    for (;;)
        loop();

    return 0;
}