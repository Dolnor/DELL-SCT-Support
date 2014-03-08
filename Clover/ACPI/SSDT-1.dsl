/*
 * Intel ACPI Component Architecture
 * AML Disassembler version 20130725-64 [Jul 30 2013]
 * Copyright (c) 2000 - 2013 Intel Corporation
 * 
 * Disassembly of SSDT-1.aml, Mon Feb 24 20:58:33 2014
 *
 * Original Table Header:
 *     Signature        "SSDT"
 *     Length           0x0000078C (1932)
 *     Revision         0x02
 *     Checksum         0xD9
 *     OEM ID           "DELL "
 *     OEM Table ID     "PollDevc"
 *     OEM Revision     0x00001000 (4096)
 *     Compiler ID      "INTL"
 *     Compiler Version 0x20130725 (538117925)
 */
DefinitionBlock ("SSDT-1.aml", "SSDT", 2, "DELL ", "PollDevc", 0x00001000)
{

    External (_SB_.PCI0.LPCB, DeviceObj)
    External (_SB_.PCI0.LPCB.EC0_.ACIN, IntObj) // AC Adapter Status Bit
    External (_SB_.PCI0.LPCB.EC0_.DTS1, IntObj) // Digital Thermal Sensor on CPU Heatsink
    External (_SB_.PCI0.LPCB.EC0_.DTS2, IntObj) // Digital Thermal Sensor on PCH Die
    External (_SB_.PCI0.LPCB.EC0_.FANH, IntObj) // Fan Tachometer reading High order
    External (_SB_.PCI0.LPCB.EC0_.FANL, IntObj) // Fan Tahcometer reading Low order
    External (_SB_.PCI0.LPCB.EC0_.FLVL, IntObj) // Active Fan Level
    External (_SB_.PCI0.LPCB.EC0_.MUT0, MutexObj) // EC Mutex (Lock)
    External (_SB_.PCI0.LPCB.EC0_.OTPC, IntObj) // Optical Thermocouple CPU Heatsink
    External (_SB_.PCI0.LPCB.EC0_.SOT0, IntObj) // Motherboard Ambient Temperature
    External (_SB_.PCI0.LPCB.EC0_.MCPT, IntObj) // Memory Compartment Temperature
    External (_SB_.PCI0.LPCB.EC0_.SOT1, IntObj) // Battery Voltage (originally 1x16 bit)
    External (_SB_.PCI0.LPCB.EC0_.SYST, IntObj) //
    External (_SB_.PCI0.LPCB.EC0_.TCTL, IntObj) // Tachometer Control

    Scope (\_SB.PCI0.LPCB)
    {
        Device (SMCD)
        {
            Name (_HID, "MON0000")       // _HID: Hardware ID
            Name (_CID, "acpi-monitor")  // _CID: Compatible ID
            Name (KLVN, Zero)            // Don't use Kelvin degrees, use Celsius instead
            Name (TEMP, Package ()   // Define settings for ACPI Temp Sensors
            {
                "CPU Heatsink", 
                "TCPU", 
                "CPU Proximity", 
                "TCPP", 
                "PCH Proximity", 
                "TPCH", 
                "Mainboard", 
                "TSYS",
                "Memory Proximity",
                "TMEM"
            })
            Method (TCPP, 0, NotSerialized) // CPU Proximity Sensor
            {
                Acquire (^^EC0.MUT0, 0xFFFF)
                Store (^^EC0.DTS1, Local0)
                Release (^^EC0.MUT0)
                Return (Local0)
            }

            Method (TCPU, 0, NotSerialized) // CPU Heatsink Sensor
            {
                Acquire (^^EC0.MUT0, 0xFFFF)
                Store (^^EC0.OTPC, Local0)
                Release (^^EC0.MUT0)
                Return (Local0)
            }

            Method (TPCH, 0, NotSerialized) // PCH Die Sensor
            {
                Acquire (^^EC0.MUT0, 0xFFFF)
                Store (^^EC0.DTS2, Local0)
                Release (^^EC0.MUT0)
                Return (Local0)
            }

            Method (TSYS, 0, NotSerialized) // Motherboard Ambient Sensor
            {
                Acquire (^^EC0.MUT0, 0xFFFF)
                Store (^^EC0.SYST, Local0)
                Release (^^EC0.MUT0)
                Return (Local0)
            }
            
            Method (TMEM, 0, NotSerialized) // Memory Compartment Ambient Sensor
            {
                Acquire (^^EC0.MUT0, 0xFFFF)
                Store (^^EC0.MCPT, Local0)
                Release (^^EC0.MUT0)
                Return (Local0)
            }

            Name (TACH, Package (0x04) // Define settings for ACPI Tachometer Sensors
            {
                "Fan Control", 
                "FAN0", 
                "System Fan", 
                "FAN1"
            })
            Method (FAN1, 0, NotSerialized) // System Fan RPM Sensor
            {
                Acquire (^^EC0.MUT0, 0xFFFF)
                Store (^^EC0.FANH, Local0)
                Store (^^EC0.FANL, Local1)
                Release (^^EC0.MUT0)
                And (Local0, 0xFFFF, Local0)
                And (Local1, 0xFFFF, Local1)
                If (LNotEqual (Local0, Zero))
                {
                    If (LEqual (Local0, 0xFFFF))
                    {
                        Store (Zero, Local0)
                    }
                    Else
                    {
                        Store (0x0100, Local2)
                        Multiply (Local0, Local2, Local3)
                        Add (Local1, Local3, Local4)
                        Store (Local4, Local0)
                    }
                }
                Else
                {
                    Store (Zero, Local0)
                }

                Return (Local0)
            }

            Method (FAN0, 0, NotSerialized) // Get Status of Fan Control Mode
            {
                Acquire (^^EC0.MUT0, 0xFFFF)
                Store (^^EC0.TCTL, Local0)
                Release (^^EC0.MUT0)
                If (LEqual (Local0, One))
                {
                    Return (One)           // If 1 is returned - fan mode auto
                }

                If (LEqual (Local0, Zero))
                {
                    Return (0x02)         // If 0 is returned - fan mode steady (locked)
                }

                Return (Zero)
            }

            Name (VOLT, Package (0x02)    // Define settings for ACPI Voltage Sensors
            {
                "Battery", 
                "VBAT"
            })
            Method (VBAT, 0, NotSerialized) // Internal Battery Voltage Sensor
            {
                Acquire (^^EC0.MUT0, 0xFFFF)
                Store (^^EC0.SOT0, Local0)
                Store (^^EC0.SOT1, Local1)
                Release (^^EC0.MUT0)
                And (Local0, 0xFFFF, Local0)
                And (Local1, 0xFFFF, Local1)
                If (LNotEqual (Local0, Zero))
                {
                    If (LEqual (Local0, 0xFFFF))
                    {
                        Store (Zero, Local0)
                    }
                    Else
                    {
                        Store (0x0100, Local2)
                        Multiply (Local0, Local2, Local3)
                        Add (Local1, Local3, Local4)
                        Store (Local4, Local0)
                    }
                }
                Else
                {
                    Store (Zero, Local0)
                }

                Return (Local0)
            }
        }

        Device (PLLD)    // ACPI Polling Device
        {
            Name (_HID, EisaId ("PRB0000"))  // _HID: Hardware ID
            Name (_CID, "acpi-probe")  // _CID: Compatible ID
            Name (TRPP, 0x40)  // Fan Trip Temperature Passive Mode
            Name (TRPA, 0x3E)  // Fan Trip Temperature Audible Mode
            Name (SAFE, 0x34)  // Safe Temperature to Override the Fan
            Name (STDY, 0xBB8) // Fan Steady Speed (3000 rpm here) for Audible Mode
            
            Name (LIST, Package (0x03) // List of profiles to display from ACPIProbe menu in HWMonitor
            {
                "PRO1", 
                "PRO2", 
                "PRO3"
            })
            Name (ACTV, "PRO3") // Activate default profile with name PRO3. Change this to your liking
            Name (PRO1, Package (0x06)
            {
                "Audible",  // Profile name
                0x03E8,     // EC data update interval, ms
                Zero,       // Update timeout, ms .. never
                Zero,       // No Console logging required, set to 1 if needed otherwise
                "TAVG",     // Names of methods to check ..
                "FAUD"
            })
            Name (PRO2, Package (0x06)
            {
                "Passive", 
                0x03E8, 
                Zero, 
                Zero, 
                "TAVG", 
                "FPAS"
            })
            Name (PRO3, Package (0x05)
            {
                "Automatic", 
                0x03E8, 
                0x03E8,     // Timeout after 1 second
                One,        // Output data to Console
                "FRST"
            })

            Name (FHST, Buffer (0x10) // CPU Die temp history
            {
                /* 0000 */   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                /* 0008 */   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
            })
            Name (FIDX, Zero)         // Current index in buffer above
            Name (FNUM, Zero)         // Number of entries in above buffer to count in avg
            Name (FSUM, Zero)         // Current sum of entries in buffer
            
            Method (TAVG, 0, Serialized)
            {
                Store (^^SMCD.TCPP (), Local0) // Store CPU Die temp sa Local0
                
                // Calculate average temperature
                Add (Local0, FSUM, Local1)
                Store (FIDX, Local2)
                Subtract (Local1, DerefOf (Index (FHST, Local2)), Local1)
                Store (Local0, Index (FHST, Local2))
                Store (Local1, FSUM) // Local2 is new sum
                
                // Adjust current index into temp table
                Increment (Local2)
                If (LGreaterEqual (Local2, SizeOf (FHST)))
                {
                    Store (Zero, Local2)
                }
                Store (Local2, FIDX)
                
                // Adjust total items collected in temp table
                Store (FNUM, Local2)
                If (LNotEqual (Local2, SizeOf (FHST)))
                {
                    Increment (Local2)
                    Store (Local2, FNUM)
                }
                // Local2 is new sum, Local3 is number of entries in sum
                Divide (Local1, Local2, , Local0)    // Local0 is now average temp
                Return (Local0)                      // Return average temp
            }

            Method (ADST, 0, Serialized)    // Get AC Adapter Status Bit 
            {
                Acquire (^^EC0.MUT0, 0xFFFF)
                Store (^^EC0.ACIN, Local0)
                Release (^^EC0.MUT0)
                Return (Local0)
            }

            Method (FAUD, 0, NotSerialized) // Audible Profile Behavior
            {
                Store (TAVG (), Local0)    // Geta average temperature
                Store (ADST (), Local3)    // Get adapter status
                Store (^^SMCD.FAN1 (), Local2)    // Get current system fan rpm
                Acquire (^^EC0.MUT0, 0xFFFF)
                Store (^^EC0.FLVL, Local1)        // Get current system fan level
                Release (^^EC0.MUT0)
                
                If (LNotEqual (Local3, Zero))     // If running on AC power
                {
                    If (LNotEqual (Local1, 0xFF)) // If fan control mode is not overriden 
                    {
                        If (LAnd (LLessEqual (Local0, SAFE), LEqual (Local1, One))) // if avg temp is <= safe temp and fan level is 1
                        {
                            Acquire (^^EC0.MUT0, 0xFFFF)
                            Store (Zero, ^^EC0.FLVL) // make fan drop speed gradually
                            Release (^^EC0.MUT0)
                        }

                        If (LAnd (LNotEqual (Local2, Zero), LAnd (LLessEqual (Local0, 
                            0x34), LLessEqual (Local2, STDY)))) // if fan speed if not zero, avg temp <= safe temp and rpm is less then requested
                        {
                            Acquire (^^EC0.MUT0, 0xFFFF)
                            Store (Zero, ^^EC0.TCTL) // clear fan tachometer control bit and override automatic control
                            Release (^^EC0.MUT0)
                        }
                    }
                    Else // if fan control is overriden with steady speed
                    {
                        // if avg temp has reach trip temp, or if fan speed has dropped to zero or it stuck at a higher speed than requested 
                        If (LOr (LGreaterEqual (Local0, TRPA), LOr (LEqual (Local2, Zero), LGreater (Local2, STDY)))) 
                        {
                            FRST () // set tachometer control to auto
                        }
                    }
                }
                Else // if suddenly running on battery
                {
                    FRST () // set tachometer control to auto
                }

                Return (Local1)
            }

            Method (FPAS, 0, NotSerialized) // Passive Profile Behavior - can work on AC and battery, fan will not run
            {
                Store (TAVG (), Local0)
                Store (^^SMCD.FAN1 (), Local2)
                Acquire (^^EC0.MUT0, 0xFFFF)
                Store (^^EC0.FLVL, Local1)
                Release (^^EC0.MUT0)
                
                If (LNotEqual (Local1, 0xFF)) // If fan control is not overriden
                {
                    If (LAnd (LLessEqual (Local0, SAFE), LEqual (Local1, One))) // if avg tems is safe and fan is runnin at level 1
                    {
                        Acquire (^^EC0.MUT0, 0xFFFF)
                        Store (Zero, ^^EC0.FLVL) // make fan drop rpms gradually
                        Release (^^EC0.MUT0)
                    }

                    If (LAnd (LLessEqual (Local0, SAFE), LEqual (Local2, Zero))) // if fan has turned off completely
                    {
                        Acquire (^^EC0.MUT0, 0xFFFF)
                        Store (Zero, ^^EC0.TCTL) // clear fan tachometer control bit and override automatic control
                        Release (^^EC0.MUT0)
                    }
                }
                Else // if ec fan control is overriden
                {
                    If (LGreaterEqual (Local0, TRPP)) // if avg temp reached trip temp
                    {
                        FRST () // set tachometer control to auto
                    }
                }

                Return (Local1)
            }

            Method (FRST, 0, NotSerialized)    // Fan Reset Profile - resets mode to automatic fan control
            {
                Acquire (^^EC0.MUT0, 0xFFFF)
                Store (One, ^^EC0.TCTL)
                Release (^^EC0.MUT0)
                Return ("Reset")
            }
        }
    }
}

