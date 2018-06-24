# MetaBalls on the Digilent Arty FPGA

This is a short introduction to VGA, MetaBalls and fixed point mathematics on the Digilent Arty FPGA. I suspect this will run on various FPGAs that have some form of output to VGA.

The program creates two buffers of SRAM. It writes to one whilst displaying the other - essentially double buffering. Each pixel position passes through the metaball field function, spitting out a fixed point value. These are summed by the fixed point addition function, resulting in a final colour.

Much of this code is taken from the excellent website [https://timetoexplore.net/](https://timetoexplore.net/) by Will Green. Take a look at his excellent tutorials to learn more about the basics.

Finally, this short project makes use of the [https://opencores.org/project/fixed_point_arithmetic_parameterized](Fixed Point Arithmetic Modules at OpenCores.org). I have included them with the project in their entiriety to make it easier for people wishing to build this themselves.

## Versions and issues. 

This project is ongoing. Things still to do:

* Removing tiling bug
* Increase resolution
* Gradients and better colours

## Resources

*[https://benjamin.computer](https://benjamin.computer) - Project page
*[https://opencores.org/project/fixed_point_arithmetic_parameterized](https://opencores.org/project/fixed_point_arithmetic_parameterized) - The fixed point arithmetic modules used in this project.
*[https://timetoexplore.net/](https://timetoexplore.net/) - Will Green's site, where several of the modules originate.
*[http://jamie-wong.com/2014/08/19/metaballs-and-marching-squares](http://jamie-wong.com/2014/08/19/metaballs-and-marching-squares)