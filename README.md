
<html>
    <style>
        .subtitle   {color: #64C7E9;
                    margin-bottom:-10px},
        .center {
                    display: block;
                    margin-left: auto;
                    margin-right: auto;
                    width: 50%;
                }
    </style>
</html>







<h1 style = "text-align:center">TonaFlow - A Free Program for ECG Processing</h1>

<!-- // Tonaflow logo -->
<p align='center'>
    <img src='./Resources/devsys_logo.png' height=100> 
</p>
<p align='center'>
    <img src=https://i.imgur.com/SftJL0e.png height=190> 
</p>


<!-- Start -->

<h1 class = 'subtitle'> About </h1>

____
TonaFlow is a free and open-source program that aims to make standardized ECG processing free and easy for everyone. 

TonaFlow is currently under heavy development, expect changes as time passes.


<h1 class = 'subtitle'> Authors </h1>

____
- Manash Sahoo - University of Houston, TIMES
- Jeremy I. Borjon = University of Houston, TIMES



<h1 class = 'subtitle'> Table of Contents </h1>

___
- [Installation](#install)
    - [Mac](#install_mac)
    - [Windows](#install_windows)
    - [Linux/Debian](#install_linux)
    - [Running with MATLAB](#install_matlab)
- [Usage](#usage)
    - [Data Formatting](#usage_dataformatting)
    - [Data Traversal](#usage_datatraversal)
    - [Filtering](#usage_filtering)
    - [Finding Heart Beats and Calculating Heart Rate](#usage_heartbeats)
    - [Adding and Removing Heart Beats](#usage_addremoval)
    - [Removing Sections of Data](#usage_dataremoval)
    - [Exporting Data](#usage_exportdata)
    - [Saving/Loading a Project](#usage_saveload)
- [Under the Hood](#dev)
    - [Filtering with the CWT](#dev_filt)
    - [Finding Heartbeats using Dynamic Thresholding](#dev_threshholding)
    - [Calculating Heart Rate using Convolution](#dev_conv)
    - [Removing Data when using Convolution](#dev_removal)




<h1 name = 'install' class = "subtitle" > Installation </h1>

---
<h3 name = 'install_mac'> Mac OSX </h3>

<h3 name = 'install_windows'> Windows </h3>

<h3 name = 'install_linux'> Linux/Debian </h3>

<h3 name = 'install_mac'> Running with MATLAB</h3>
If you have a MATLAB license, TonaFlow can be run directly in the environment.

1. Download the zip or clone the repository using Git
2. Unzip the folder in an enclosing folder of your choice
3. Change your MATLAB working directory to `.../TonaFlow/`
4. Run `main` in the command window

<h1 name = 'usage' class='subtitle'> Usage </h1>

---
<h3 name = 'usage_dataformatting'> Data Formatting </h3>

To maximize access, TonaFlow only accepts data from a `.csv` or `.xlsx`. These are ubiquitous file types used by the majority of systems. 

The contents of your file should follow the following format, with the first column being time, and the second column being measurement:
<center>


| $t$ | $ECG$ |
| --- | --- |
| 0.1 | $1100$|
| 0.2 | $1200$|
| 0.3 | $1300$|
| 0.4 | $800$|
| ... | $...$|


</center> 

There should be no duplicate values in column $t$, and both columns should be of the same length. 

There is no need to include a sampling rate with your file. Sampling rate can be estimated from column $t$, by using the equation

$$ Fs = \frac{1}{mean(\frac{d}{dt}(t))}$$





<h3 name = 'usage_datatraversal'> Data Traversal </h3>

---
Because TonaFlow is built using the MATLAB GUI Designer, it utilizes the standard MATLAB plots. In short, there are 3 main buttons on the top right of the axes that you will use while using TonaFlow.
1. Zoom In
2. Zoom Out
3. Home

<h3 name = 'usage_dataformatting'> Using the arrow keys </h3> 
Sessions can be very long, and take a while to parse through. While you can click and drag along the plot to move along the X axis, this can be tiresome. If you make sure that the axes is "focused" by first clicking on it, you can use the left and right arrow keys to move along the Y_Axis. 

Change the "Keypress Factor" edit field, to edit the amount of step for each keypress.



<h3 name = 'usage_filtering'>Filtering</h3>

___
Sometimes, electrocardiograms include artifacts or oscillatory noise due to movement or breathing. While TonaFlow can handle some amounts of oscillation, it is best practice to filter these signals. 

While many tools use traditional butterworth filters to filter frequencies, TonaFlow uses the Continuous Wavelet Transform (CWT). You can read more about wavelets [here]() or the MATLAB `cwt` function [here]().

After loading a signal, click `ECG` on the top toolbar, and then `Filter with CWT`.
![Imgur](https://i.imgur.com/b1H5qcl.png)

This will bring up the CWT Bandpass window. 
![Imgur](https://i.imgur.com/PawfrvY.png)
Adjust the upper and lower frequency values to effectively remove low and high oscillatory noise. In many ECG recordings, low oscillatory noise corresponds to variation in respiration, while high oscillatory noise corresponds to movement. In any case, these are unwanted portions of the signal. 

The frequency bounds in the CWT Bandpass window automatically populate to the possible frequency bounds of the signal. Adjust these frequencies until the ECG is as free of noise as possible. In this case, passing frequencies under 1Hz significantly cleans the signal. 

![Imgur](https://i.imgur.com/0LslqKx.png)

Now, our signal is sufficiently proecessed to make beat detection easier and more efficient. 



<h3 name = 'usage_heartbeats'>Finding Heart Beats and Calculating Heart Rate</h3>

___
In order to calculate heart rate, we need to detect where these beats are happening. To begin calculating heart rate and finding heart beats, go to `ECG` and click `Calculate Heart Rate`.
![Imgur](https://i.imgur.com/GtMtMyH.png)

This will bring up the beat detection window.
![Imgur](https://imgur.com/QnYcnMY.png)
This window is designed to allow users to preview their threshold as they adjust parameters. Adjust the `Preview Size` edit field to view a smaller or larger window of data, and use the bottom slider to traverse across the X-axis. 

### Specifying a Threshold Window
TonaFlow calculates heartbeats through use of a <strong> dynamic threshold</strong>. 
This threshold is calculated every 1 second by default. If you find that your threshold is varying too much, then adjust this value. 

### Absolute Value
Sometimes, R peaks can manifest in different ways. Sometimes, they pertrude upwards while other times, they pertrude only downwards. You can select the `Use Absolute Value` checkbox to perform the detection on the ABS of the signal, that way downwards R peaks are not missed. 

### Convolution Window Size
To calculate heart rate, TonaFlow uses convolution. For more information about convolution, visit the [Under the Hood](#dev) section. 

































<h1 name = 'dev' class = 'subtitle' > Under the Hood </h1>

___


<h3 name = 'dev_filt'> Filtering with the CWT </h3>

First, the CWT of the ECG signal $x$ is calculated


$$ W_f(a, b) = \int_{-\infty}^{\infty} f(x) \cdot \psi_{a,b}(x) \, dx $$

where $\psi_{a,b}$ is the wavelet $\psi$ at translation $a$ and scale $b$. TonaFlow uses the `bump` wavelet, which according to [MATLAB]() can be defined as:
$$
\psi(x) = 
\begin{cases} 
e^{1 - \frac{1}{1 - (\frac{x - \mu}{\sigma})^2}} & \text{for } |x - \mu| < \sigma, \\
0 & \text{otherwise.}
\end{cases}
$$

Then, the signal is reconstructed using the inverse-CWT within the specified frequency bounds
$$ f(x) = \frac{1}{C_\psi} \int_{-\infty}^{\infty} \int_{-\infty}^{\infty} \frac{1}{a^2} W_f(a, b) \cdot \psi_{a,b}(x) \, da \, db $$
