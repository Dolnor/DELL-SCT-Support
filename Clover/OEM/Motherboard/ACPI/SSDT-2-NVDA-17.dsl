/*
 * Intel ACPI Component Architecture
 * AML Disassembler version 20130725-64 [Jul 30 2013]
 * Copyright (c) 2000 - 2013 Intel Corporation
 * 
 * Disassembly of SSDT-2.aml, Mon Feb 24 13:43:47 2014
 *
 * Original Table Header:
 *     Signature        "SSDT"
 *     Length           0x00000FCD (4045)
 *     Revision         0x02
 *     Checksum         0xFC
 *     OEM ID           "DELL "
 *     OEM Table ID     "SsdtIGPU"
 *     OEM Revision     0x00001000 (4096)
 *     Compiler ID      "INTL"
 *     Compiler Version 0x20130725 (538117925)
 */
DefinitionBlock ("SSDT-2.aml", "SSDT", 2, "DELL ", "SsdtIGPU", 0x00001000)
{

    External (_SB_.ADP1, DeviceObj)
    External (_SB_.PCI0, DeviceObj)
    External (_SB_.PCI0.EHC1, DeviceObj)
    External (_SB_.PCI0.EHC2, DeviceObj)
    External (_SB_.PCI0.HDEF, DeviceObj)
    External (_SB_.PCI0.IGPU, DeviceObj)
    External (_SB_.PCI0.IGPU.CBLV, IntObj)
    External (_SB_.PCI0.IGPU._DOS, MethodObj)
    External (_SB_.PCI0.LPCB, DeviceObj)
    External (_SB_.PCI0.LPCB.EC0_, DeviceObj)
    External (_SB_.PCI0.LPCB.EC0_.KBBL, IntObj)
    External (_SB_.PCI0.LPCB.EC0_.TCTL, IntObj)
    External (_SB_.PCI0.LPCB.EC0_._O80, MethodObj)
    External (_SB_.PCI0.LPCB.EC0_._O81, MethodObj) 
    External (_SB_.PCI0.LPCB.EC0_._O8A, MethodObj) 
    External (_SB_.PCI0.LPCB.EC0_._O8C, MethodObj)
    External (_SB_.PCI0.LPCB.EC0_._OAF, MethodObj)  
    External (_SB_.PCI0.LPCB.PS2K, DeviceObj)
    External (_SB_.PCI0.LPCB.PS2M, DeviceObj)
    External (_SB_.PCI0.RP04.PXSX, DeviceObj)
    External (_SB_.PCI0.RP06.PXSX, DeviceObj)
    External (_SB_.PCI0.SATA, DeviceObj)
    External (_SB_.PCI0.SBUS, DeviceObj)
    External (IGDS, IntObj)
    External (BRGA, IntObj) //brightness on AC power
    External (BRGD, IntObj) //brightness on DC power
    External (PWRS, IntObj) //active power source

    Scope (\)
    {
        // Check whether OS is Darwin, used in SBUS and HDA injection on genuine Macs
        Method (OSDW, 0, NotSerialized)
        {
            If (CondRefOf (_OSI, Local0))
            {
                If (_OSI ("Darwin"))
                {
                    Return (One)
                }
            }

            Return (Zero)
        }
    }

    Scope (\_SB)
    {
        // Origin: https://github.com/RehabMan/HP-ProBook-4x30s-DSDT-Patch/blob/master/12_Brightness.txt
        
        // normal PNLF declares (note some of this probably not necessary)
        Device (PNLF)
        {
            Name (_ADR, Zero)  // _ADR: Address
            Name (_HID, EisaId ("APP0002"))  // _HID: Hardware ID
            Name (_CID, "backlight")  // _CID: Compatible ID
            Name (_UID, 0x0A)  // _UID: Unique ID
            Name (_STA, 0x0B)  // _STA: Status
            
			// define hardware register access for brightness
			// lower nibble of BAR1 is status bits and not part of the address
            OperationRegion (BRIT, SystemMemory, And(\_SB.PCI0.IGPU.BAR1, Not(0xF)), 0xe1184)
            Field (BRIT, AnyAcc, Lock, Preserve)
            {
                Offset (0x48250), 
                LEV2,   32, 
                LEVL,   32, 
                Offset (0x70040), 
                P0BL,   32, 
                Offset (0xC8250), 
                LEVW,   32, 
                LEVX,   32, 
                Offset (0xE1180), 
                PCHL,   32
            }
		
            Name (STPS, 0x04)  // STPS: number of steps in between for one level
            Name (LMAX, 0x00)  // LMAX: use 0x710 to force OS X value .. any other value or 0 to capture BIOS settings
            Name (KMAX, 0x710) // KMAX: defines the unscaled range in the _BCL table below
            Name (KPCH, 0) // KPCH: saved value for PCHL
            Name (XOPT, Zero) // Use XOPT=1 to disable smooth transitions
            Name (XRGL, 0x28) // XRGL/XRGH: defines the valid range
            Name (XRGH, 0x0710)
            Name (KLVX, 0x07100000) // KLVX is initialization value for LEVX
            
            Name (CBAR, Package ()  // Cold Boot BIOS Backlight Levels
            {
                0x06, 0x06, 0x0C, 0x12, 0x18, 0x1E, 0x24, 0x2A, 0x30,
                0x36, 0x3C, 0x42, 0x48, 0x4E, 0x54, 0x5A, 0x64 
            })
            
            Name (ECAR, Package ()  // EC Backlight Levels
            {
                0x00, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 
                0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F 
            })
            
            Name (_BCL, Package (0x43)  // _BCL: Brightness Control Levels
            {
                1807, 479, //ac + dc level group
                0, 229, 254, 279, 304, //0x00 level group
                329, 354, 379, 404, //0x01 level group
                429, 454, 479, 504, //0x02 level group
                529, 554, 579, 604, //0x03 level group
                629, 654, 679, 704, //0x04 level group
                729, 754, 779, 804, //0x05 level group
                829, 854, 879, 904, //0x06 level group
                929, 954, 979, 1004, //0x07 level group
                1029, 1054, 1079, 1104, //0x08 level group
                1129, 1154, 1179, 1204, //0x09 level group
                1229, 1254, 1279, 1304, //0x0a level group
                1329, 1354, 1379, 1404, //0x0b level group
                1429, 1454, 1479, 1504, //0x0c level group
                1529, 1554, 1579, 1604, //0x0d level group
                1629, 1654, 1679, 1704, //0x0e level group
                1729, 1754, 1779, 1808  //0x0f level group
            })
            
            // _INI deals with differences between native setting and desired
			Method (_INI, 0, NotSerialized)
			{
                // save value of PCHL for later
				Store(PCHL, KPCH)
				// determine LMAX to use
				If (LNot(LMAX)) 
				{ 
					Store(ShiftRight(LEVX,16), LMAX) 
				}
				If (LNot(LMAX)) 
				{ 
					Store(KMAX, LMAX) 
				}
				Store(ShiftLeft(LMAX,16), KLVX)
				If (LNotEqual(LMAX, KMAX))
				{
					// scale all the values in _BCL to the PWM max in use
					Store(0, Local0)
					While (LLess(Local0,SizeOf(_BCL)))
					{
						Store(DerefOf(Index(_BCL,Local0)), Local1)
						Divide(Multiply(Local1,LMAX), KMAX,, Local1)
						Store(Local1, Index(_BCL,Local0))
						Increment(Local0)
					}
					// also scale XRGL and XRGH values
					Divide(Multiply(XRGL,LMAX), KMAX,, XRGL)
					Divide(Multiply(XRGH,LMAX), KMAX,, XRGH)
				}
				// adjust values to desired LMAX
				Store(ShiftRight(LEVX,16), Local1)
				If (LNotEqual(Local1, LMAX))
				{
					Store(LEVL, Local0)
					If (LOr(LNot(Local0),LNot(Local1))) 
					{ 
						Store(LMAX, Local0) Store(LMAX, Local1) 
					}
					Divide(Multiply(Local0,LMAX), Local1,, Local0)
					//REVIEW: wait for vblank before setting new PWM config
					//Store(P0BL, Local7)
					//While (LEqual (P0BL, Local7)) {}
					If (LGreater(LEVL, LMAX))
					{ 
						Store(KLVX, LEVX) Store(Local0,LEVL) 
					}
					Else
					{ 
						Store(Local0,LEVL) Store(KLVX, LEVX) 
					}
				}
			}
            
            // _BCM/_BQC: set/get for brightness level in regular control mode
            Method (_BCM, 1, NotSerialized)  // _BCM: Brightness Control Method
            {
                // initialize for consistent backlight level before/after sleep
                If (LNotEqual(PCHL, KPCH)) 
                { 
                    Store(KPCH, PCHL) 
                }
                If (LNotEqual (LEVW, 0x80000000))
                {
                    Store (0x80000000, LEVW)
                }

                If (LNotEqual (LEVX, KLVX))
                {
                    Store (KLVX, LEVX)
                }
                // store new backlight level
                Store (Match (_BCL, MGE, Arg0, MTR, Zero, 0x02), Local0)
                If (LEqual (Local0,Ones))
                {
                    Subtract (SizeOf (_BCL), One, Local0)
                }

                If (LNotEqual (LEV2, 0x80000000))
                {
                    Store (0x80000000, LEV2)
                }

                Store (DerefOf (Index (_BCL, Local0)), LEVL)
            }
			
            Method (_BQC, 0, NotSerialized)  // _BQC: Brightness Query Current
            {
                Store (Match (_BCL, MGE, LEVL, MTR, Zero, 0x02), Local0)
                If (LEqual (Local0,Ones))
                {
                    Subtract (SizeOf (_BCL), One, Local0)
                }

                Return (DerefOf (Index (_BCL, Local0)))
            }
			
            Method (_DOS, 1, NotSerialized)  // _DOS: Disable Output Switching
            {
                ^^PCI0.IGPU._DOS (Arg0)
            }

            // extended _BCM/_BQC for setting "in between" levels also known as subtle brightness control
            Method (XBCM, 1, NotSerialized)
            {
                // initialize for consistent backlight level before/after sleep
                If (LNotEqual(PCHL, KPCH)) 
                { 
                    Store(KPCH, PCHL) 
                }
                If (LNotEqual (LEVW, 0x80000000))
                {
                    Store (0x80000000, LEVW)
                }

                If (LNotEqual (LEVX, KLVX))
                {
                    Store (KLVX, LEVX)
                }
                
                // store new backlight level
                If (LGreater (Arg0, XRGH))
                {
                    Store (XRGH, Arg0)
                }

                If (LAnd (Arg0, LLess (Arg0, XRGL)))
                {
                    Store (XRGL, Arg0)
                }

                If (LNotEqual (LEV2, 0x80000000))
                {
                    Store (0x80000000, LEV2)
                }

                Store (Arg0, LEVL)
            }

            Method (XBQC, 0, NotSerialized)
            {
                Store (LEVL, Local0)
                If (LGreater (Local0,XRGH))
                {
                    Store (XRGH, Local0)
                }

                If (LAnd (Local0,LLess (Local0,XRGL)))
                {
                    Store (XRGL, Local0)
                }

                Return (Local0)
            }
            
            // preserve brightness level for BIOS
            Method (SAVE, 1, NotSerialized)
            {
                // get level position in _BCL array
                Store (Match (_BCL, MGE, Arg0, MTR, Zero, 0x02), Local0)
                If (LEqual (Local0,Ones))
                {
                    Subtract (SizeOf (_BCL), One, Local0)
                }
                
                // divide index by the number of steps for one level
                // determine reg values for cold boot level consistency
                Divide (Local0, STPS,, Local0)
                Store (DerefOf (Index (ECAR, Local0)), Local1)
                Store (DerefOf (Index (CBAR, Local0)), Local2)
                Xor (Local2, 0x80000000, Local2)
                
                // write register values
                Store (Local2, \_SB.PCI0.IGPU.CBLV)
                // determine power source used, different regs for ac/dc power
                If (PWRS) 
                {
                    Store (Local1,BRGA)
                }
                Else 
                {
                    Store (Local1,BRGD)
                }
            }
        }
        
        // add missing power resources (same as for LID) so that AC adapter would be picked by apple driver
        // as of RehabMan's ACPIBatteryManager 1.52 this is not reqlly needed, because h eimplemented his own ac adapter class
        Scope (\_SB.ADP1)
        {
            Name (_PRW, Package (0x02)  // _PRW: Power Resources for Wake
            {
                0x0A, 
                0x03
            })
        }
    }

    Scope (\_SB.PCI0)
    {
        // Expose Chipset Memory controller Hub to IORegistry
        Device (MCHC)
        {
            Name (_ADR, Zero)  // _ADR: Address
            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                Store (Package (0x02)
                    {
                        "subsystem-vendor-id", 
                        Buffer (0x04)
                        {
                             0x6B, 0x10, 0x00, 0x00
                        }
                    }, Local0)
                DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                Return (Local0)
            }
        }

        // Expose Management Engine Interface name to IOReg
        Device (MEI)
        {
            Name (_ADR, 0x00160000)  // _ADR: Address
        }

        // Define EHCI port advanced power resources and set it as Apple Built-in device to fix sleep
        Scope (\_SB.PCI0.EHC1)
        {
            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                Store (Package (0x13)
                    {
                        "subsystem-id", 
                        Buffer (0x04)
                        {
                             0x70, 0x72, 0x00, 0x00
                        }, 

                        "subsystem-vendor-id", 
                        Buffer (0x04)
                        {
                             0x86, 0x80, 0x00, 0x00
                        }, 

                        "built-in", 
                        Buffer (One)
                        {
                             0x00
                        }, 

                        "AAPL,clock-id", 
                        Buffer (One)
                        {
                             0x01
                        }, 

                        "AAPL,current-available", 
                        0x0834, 
                        "AAPL,current-extra", 
                        0x0898, 
                        "AAPL,current-extra-in-sleep", 
                        0x0640, 
                        "AAPL,max-port-current-in-sleep", 
                        0x0834, 
                        "AAPL,device-internal", 
                        0x02, 
                        Buffer (One)
                        {
                             0x00
                        }
                    }, Local0)
                DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                Return (Local0)
            }
        }

        Scope (\_SB.PCI0.EHC2)
        {
            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                Store (Package (0x13)
                    {
                        "subsystem-id", 
                        Buffer (0x04)
                        {
                             0x70, 0x72, 0x00, 0x00
                        }, 

                        "subsystem-vendor-id", 
                        Buffer (0x04)
                        {
                             0x86, 0x80, 0x00, 0x00
                        }, 

                        "built-in", 
                        Buffer (One)
                        {
                             0x00
                        }, 

                        "AAPL,clock-id", 
                        Buffer (One)
                        {
                             0x02
                        }, 

                        "AAPL,current-available", 
                        0x0834, 
                        "AAPL,current-extra", 
                        0x0898, 
                        "AAPL,current-extra-in-sleep", 
                        0x0640, 
                        "AAPL,max-port-current-in-sleep", 
                        0x0834, 
                        "AAPL,device-internal", 
                        0x02, 
                        Buffer (One)
                        {
                             0x00
                        }
                    }, Local0)
                DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                Return (Local0)
            }
        }

        // Mimic Series-6 LPC Bridge used by Apple to reduce system temperatures
        Scope (\_SB.PCI0.LPCB)
        {
            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                Store (Package (0x0A)
                    {
                        "device-id", 
                        Buffer (0x04)
                        {
                             0x49, 0x1C, 0x00, 0x00
                        }, 

                        "IOName", 
                        Buffer (0x0D)
                        {
                            "pci8086,1c49"
                        }, 

                        "name", 
                        Buffer (0x0D)
                        {
                            "pci8086,1c49"
                        }, 

                        "subsystem-id", 
                        Buffer (0x04)
                        {
                             0x70, 0x72, 0x00, 0x00
                        }, 

                        "subsystem-vendor-id", 
                        Buffer (0x04)
                        {
                             0x86, 0x80, 0x00, 0x00
                        }
                    }, Local0)
                DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                Return (Local0)
            }
        }

        Scope (\_SB.PCI0.LPCB.PS2K)
        {
            // expose keyboard device to RehabMan's VoodooPS2 Driver
            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                If (LEqual (Arg2, Zero))
                {
                    Return (Buffer (One)
                    {
                         0x03
                    })
                }

                Return (Package (0x04)
                {
                    "RM,oem-id", 
                    "DELL",
                    "RM,oem-table-id",
                    "SNB-CPT"
                })
            }
            
            // wireless radio toggle switch
            Method (RKA0, 1, NotSerialized)
            {
                If (Arg0)
                {
                    \_SB.PCI0.LPCB.EC0._O8C ()
                }
            }

            // control keyboard backlight in special f-key mode
            Method (RKA3, 1, NotSerialized)
            {
                If (Arg0)
                {
                    Store (^^EC0.KBBL, Local0)
                    If (LEqual(Local0, Zero))
                    {
                        Store (0x02, ^^EC0.KBBL)
                    }
                    If (LEqual(Local0, 0x02))
                    {
                        Store (0x01, ^^EC0.KBBL)
                    }
                    If (LEqual(Local0, One))
                    {
                        Store (0x00, ^^EC0.KBBL)
                    }
                    \_SB.PCI0.LPCB.EC0._O8A ()
                }
            }
        }
        
        Scope (\_SB.PCI0.LPCB.PS2M)
        {
            // method to toggle LED status with VoodooPS2 1.8.11 and later
            Method (TPDN, 1, NotSerialized)
            {
                If (LEqual(Arg0,0xFFFF))
                {
                    // disable LED if shutdown or restart issued, requires VoodooPS2Daemon
                    Store(Zero, Arg0)
                    // reset fan to autoomatic control mode regardless
                    Store(One, ^^EC0.TCTL)
                }
                Else
                {
                    // we wait for EC to set LED if Fn+F3 pressed
                    Sleep(200) 
                }
                // only if there was no action from EC we toggle it
                If (LNotEqual(Arg0, ^^EC0.TLED))
                {
                    Store (Arg0, ^^EC0.TLED)
                }
            }
        }

        Scope (\_SB.PCI0.LPCB.EC0)
        {
            // allow to get and set touchpad LED status from EC RAM 0x45 bit 7
            OperationRegion (ECSP, EmbeddedControl, 0x45, 0x0018)           
            Field (ECSP, ByteAcc, Lock, Preserve)
            { 
                    ,   7, 
                TLED,   1, 
                Offset (0x17), // 0x5C counting from 0x00 offset
                MCPT,   8,     // memory compartment temp
            }
            // this will be invoked when Fn+F2 is pressed and will call original query in DSDT
            Method (_Q8C, 0, NotSerialized)  // _Qxx: EC Query
            {
                Notify (PS2K, 0x0208)
                Notify (PS2K, 0x0288)
                \_SB.PCI0.LPCB.EC0._O8C ()
            }
            // this will be called when Fn+F5 is pressed
            Method (_Q80, 0, NotSerialized)  // _Qxx: EC Query
            {
                Notify (PS2K, 0x0206)
                Notify (PS2K, 0x0286)
            }
            // this will be called when Fn+F4 is pressed
            Method (_Q81, 0, NotSerialized)  // _Qxx: EC Query
            {
                Notify (PS2K, 0x0205)
                Notify (PS2K, 0x0285)
            }
            // this will be called when Fn+F6 is pressed
            Method (_Q8A, 0, NotSerialized)  // _Qxx: EC Query
            {
                Notify (PS2K, 0x020C)
                Notify (PS2K, 0x028C)
                \_SB.PCI0.LPCB.EC0._O8A ()
            }
            // this will be called when Dell Support Center is pressed
            Method (_QAF, 0, NotSerialized)  // _Qxx: EC Query
            {
                Notify (PS2K, 0x0209)
                Notify (PS2K, 0x0289)
                \_SB.PCI0.LPCB.EC0._OAF ()
            }
        }
        
        // Expose Intel SMBus Controller to IORegistry and fake one that Apple uses on their Macbooks
        Scope (\_SB.PCI0.SBUS)
        {
            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                Store (Package (0x08)
                    {
                        "device-id", 
                        Buffer (0x04)
                        {
                             0x22, 0x1C, 0x00, 0x00
                        }, 

                        "revision-id", 
                        Buffer (0x04)
                        {
                             0x05, 0x00, 0x00, 0x00
                        }, 

                        "subsystem-id", 
                        Buffer (0x04)
                        {
                             0x70, 0x72, 0x00, 0x00
                        }, 

                        "subsystem-vendor-id", 
                        Buffer (0x04)
                        {
                             0x86, 0x80, 0x00, 0x00
                        }
                    }, Local0)
                DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                Return (Local0)
            }

            Device (BUS0)
            {
                Name (_CID, "smbus")  // _CID: Compatible ID
                Name (_ADR, Zero)  // _ADR: Address
                Device (BLC0)
                {
                    Name (_ADR, Zero)  // _ADR: Address
                    Name (_CID, "smbus-ddcblc")  // _CID: Compatible ID
                    Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
                    {
                        Store (Package (0x04)
                            {
                                "refnum", 
                                Zero, 
                                "address", 
                                0x28
                            }, Local0)
                        DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                        Return (Local0)
                    }

                    Method (_STA, 0, NotSerialized)  // _STA: Status
                    {
                        If (OSDW ())
                        {
                            Return (0x0F)
                        }
                        Else
                        {
                            Return (0x0B)
                        }
                    }
                }
            }

            Device (BUS1)
            {
                Name (_CID, "smbus")  // _CID: Compatible ID
                Name (_ADR, One)  // _ADR: Address
            }
        }

        // Power resources for USB3.0 controller
        Scope (\_SB.PCI0.RP04.PXSX)
        {
            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                Store (Package ()
                    {
                        "built-in", 
                        Buffer (One)
                        {
                             0x00
                        }, 

                        "AAPL,clock-id", 
                        Buffer (One)
                        {
                             0x00
                        }, 

                        "AAPL,current-available", 
                        0x0834, 
                        "AAPL,current-extra", 
                        0x0898, 
                        "AAPL,current-extra-in-sleep", 
                        0x0640, 
                        "AAPL,max-port-current-in-sleep", 
                        0x0834, 
                        "AAPL,device-internal", 
                        0x02, 
                        Buffer (One)
                        {
                             0x00
                        }
                    }, Local0)
                DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                Return (Local0)
            }
        }
        
        // Treat Ethernet as being buil-in into the system to allow sign-on to AppStore and other services
        Scope (\_SB.PCI0.RP06.PXSX)
        {
            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                Store (Package ()
                    {
                        "built-in", 
                        Buffer (One)
                        {
                             0x00
                        }, 

                        "device_type", 
                        Buffer (0x09)
                        {
                            "ethernet"
                        }
                    }, Local0)
                DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                Return (Local0)
            }
        }

        // Change SATA subsystem id to be Apple
        Scope (\_SB.PCI0.SATA)
        {
            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                Store (Package (0x04)
                    {
                        "subsystem-id", 
                        Buffer (0x04)
                        {
                             0x70, 0x72, 0x00, 0x00
                        }, 

                        "subsystem-vendor-id", 
                        Buffer (0x04)
                        {
                             0x86, 0x80, 0x00, 0x00
                        }
                    }, Local0)
                DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                Return (Local0)
            }
        }

        // HD3000 device injection
        Scope (\_SB.PCI0.IGPU)
        {
            // PCI configuration space required for proper brightness control
            OperationRegion (IGD2, PCI_Config, 0x10, 0x04)
            Field (IGD2, AnyAcc, NoLock, Preserve)
            {
                BAR1,   32
            }
            
            // IGPU Shared memory definition
            Device (^^MEM2)
            {
                Name (_HID, EisaId ("PNP0C01"))  // _HID: Hardware ID
                Name (_UID, 0x02)  // _UID: Unique ID
                Name (CRS, ResourceTemplate ()
                {
                    Memory32Fixed (ReadWrite,
                        0x20000000,         // Address Base
                        0x00200000,         // Address Length
                        )
                    Memory32Fixed (ReadWrite,
                        0x40000000,         // Address Base
                        0x00200000,         // Address Length
                        )
                })
                Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
                {
                    If (IGDS)
                    {
                        Return (CRS)
                    }

                    Return (Buffer (One)
                    {
                         0x00
                    })
                }
            }
        }
        
        // Define missing properties for AppleHDA analog and HDMI codecs and define layout to use
        Scope (\_SB.PCI0.HDEF)
        {
            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                Store (Package (0x10)
                    {
                        "MaximumBootBeepVolume", 
                        Buffer (One)
                        {
                             0x5D
                        }, 

                        "MaximumBootBeepVolumeAlt", 
                        Buffer (One)
                        {
                             0x00
                        }, 

                        "subsystem-id", 
                        Buffer (0x04)
                        {
                             0x70, 0x72, 0x00, 0x00
                        }, 

                        "subsystem-vendor-id", 
                        Buffer (0x04)
                        {
                             0x86, 0x80, 0x00, 0x00
                        }, 

                        "layout-id", 
                        Buffer (0x04)
                        {
                             0x41, 0x00, 0x00, 0x00
                        }, 

                        "hda-gfx", 
                        Buffer (0x0A)
                        {
                            "onboard-1"
                        }, 

                        "PinConfigurations", 
                        Buffer (Zero) {}, 
                        "PlatformFamily", 
                        Buffer (One)
                        {
                             0x00
                        }
                    }, Local0)
                DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                Return (Local0)
            }
        }
    }

    Method (DTGP, 5, NotSerialized)
    {
        If (LEqual (Arg0, Buffer (0x10)
                {
                    /* 0000 */   0xC6, 0xB7, 0xB5, 0xA0, 0x18, 0x13, 0x1C, 0x44,
                    /* 0008 */   0xB0, 0xC9, 0xFE, 0x69, 0x5E, 0xAF, 0x94, 0x9B
                }))
        {
            If (LEqual (Arg1, One))
            {
                If (LEqual (Arg2, Zero))
                {
                    Store (Buffer (One)
                        {
                             0x03
                        }, Arg4)
                    Return (One)
                }

                If (LEqual (Arg2, One))
                {
                    Return (One)
                }
            }
        }

        Store (Buffer (One)
            {
                 0x00
            }, Arg4)
        Return (Zero)
    }
}

