# PWM Regulated Fan Based on CPU Temperature for Raspberry Pi 4

## Parts
- Tiny fan 5v 0.10A
- Transistor 2N2222A
- 1k Resistor
- 1 Diode

[!electric_schema.jpg]

## Fan Script
Here you can edit the `GPIO` to use like `FAN_PIN = 21` (notice we are using a PWM approach) and the different speed steps based on temps. For example:
```python
tempSteps = [40, 50, 55, 60, 65, 70]
speedSteps = [0, 35, 40, 50, 70, 100]
```

### All the credits for Aerandir14 I just automated it for this installer and used on my Rpi 4
https://www.instructables.com/id/PWM-Regulated-Fan-Based-on-CPU-Temperature-for-Ras/

### Notes
If you get an error that you are not in a rpi add your user to gpio:
```sudo adduser $USER gpio```