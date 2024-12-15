#!/bin/bash

# File where the history of results will be saved
history_file="calculator_history.txt"

# Create the file if it doesn't exist
if [ ! -f $history_file ]; then
    touch $history_file
fi

# Previous result
prev_result=""

# Function to validate numeric input
function validate_number {
    local input="$1"
    if ! [[ $input =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
        echo "Invalid input, please enter a valid number."
        return 1
    fi
    return 0
}

# Function for basic calculations
function basic_calculations {
    while true; do
        echo "Please enter the mathematical expression you want to calculate."
        echo "You can use 'ans' for the previous result or type 'q' to quit."
        read expression

        # Break the loop if the user wants to quit
        if [[ "$expression" == "q" ]]; then
            echo "Returning to the main menu."
            break
        fi

        # Use the previous result if 'ans' is used
        if [[ "$prev_result" != "" ]]; then
            expression=$(echo $expression | sed "s/ans/$prev_result/g")
        fi

        # Expression to convert log(b,x) to it's log value
        expression=$(echo $expression | sed 's/log(\([^,]*\),\([^)]*\))/l(\2)\/l(\1)/g')


        # Delete unnecessary chars
        expression=$(echo $expression | sed 's/[^-+*\/^()0-9.sqrt%log,sct]//g')

        # Calculate the result with simple error handling
        if [[ "$expression" == *"%"* ]]; then
            result=$(echo "scale=0; $expression" | bc -l 2>&1)
        else
            result=$(echo "scale=10; $expression" | bc -l 2>&1)
        fi
        if [[ $? -ne 0 ]]; then
            echo "Invalid expression."
        else
            echo "Result: $result"
            prev_result=$result

            # Ask if the user wants to save the result
            echo "Do you want to save the result? (y/n):"
            read save_choice
            if [[ "$save_choice" == "y" ]]; then
                echo "$expression = $result" >> $history_file
                echo "Result saved."
            fi
        fi

        # Ask if the user wants to view the history
        echo "Do you want to view the history? (y/n):"
        read history_choice
        if [[ "$history_choice" == "y" ]]; then
            cat $history_file
        fi

        echo "Press Enter to continue or type 'q' to quit."
    done
}

# Function for unit conversions
function unit_conversions {
    while true; do
        echo "Which unit conversion would you like to perform?"
        echo "1) Meters to Kilometers"
        echo "2) Grams to Kilograms"
        echo "3) Celsius to Fahrenheit"
        echo "4) Degrees to Radians"
        echo "5) Radians to Degrees"
        echo "6) Return to the main menu"
        read unit_choice

        case $unit_choice in
            1) 
                echo "Enter the value in meters:"
                read meters
                validate_number "$meters" || continue
                kilometers=$(echo "scale=2; $meters/1000" | bc)
                echo "$meters meters = $kilometers kilometers"
                ;;
            2) 
                echo "Enter the value in grams:"
                read grams
                validate_number "$grams" || continue
                kilograms=$(echo "scale=2; $grams/1000" | bc)
                echo "$grams grams = $kilograms kilograms"
                ;;
            3) 
                echo "Enter the temperature in Celsius:"
                read celsius
                validate_number "$celsius" || continue
                fahrenheit=$(echo "scale=2; $celsius*9/5+32" | bc)
                echo "$celsius°C = $fahrenheit°F"
                ;;
            4)
                echo "Enter the angle in degrees:"
                read degrees
                validate_number "$degrees" || continue
                radians=$(echo "scale=6; $degrees*(3.141592653589793/180)" | bc)
                echo "$degrees degrees = $radians radians"
                ;;
            5)
                echo "Enter the angle in radians:"
                read radians
                validate_number "$radians" || continue
                degrees=$(echo "scale=2; $radians*(180/3.141592653589793)" | bc)
                echo "$radians radians = $degrees degrees"
                ;;
            6) 
                echo "Returning to the main menu."
                break
                ;;
            *) 
                echo "Invalid option, please try again."
                ;;
        esac
    done
}

# Main Menu
while true; do
    echo "Which operation would you like to perform?"
    echo "1) Basic Calculations (Addition, subtraction, multiplication, division, exponentiation, sqrt, log)"
    echo "2) Unit Conversions"
    echo "3) Exit"
    read main_choice

    case $main_choice in
        1) 
            basic_calculations
            ;;
        2) 
            unit_conversions
            ;;
        3) 
            echo "Bye"
            break
            ;;
        *) 
            echo "Invalid option, please try again."
            ;;
    esac
done
