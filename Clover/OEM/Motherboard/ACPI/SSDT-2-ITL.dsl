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
    
    /* You need the following patches applied to your original DSDT table in order for this ACPI table to take effect.
    
    				<dict>
					<key>Comment</key>
					<string>ADP0 - ADP1</string>
					<key>Find</key>
					<data>QURQMA==</data>
					<key>Replace</key>
					<data>QURQMQ==</data>
				</dict>
				<dict>
					<key>Comment</key>
					<string>SAT0 - SATA</string>
					<key>Find</key>
					<data>U0FUMA==</data>
					<key>Replace</key>
					<data>U0FUQQ==</data>
				</dict>
				<dict>
					<key>Comment</key>
					<string>GFX0 - IGPU</string>
					<key>Find</key>
					<data>R0ZYMA==</data>
					<key>Replace</key>
					<data>SUdQVQ==</data>
				</dict>
				<dict>
					<key>Comment</key>
					<string>Q80 - O80</string>
					<key>Find</key>
					<data>X1E4MA==</data>
					<key>Replace</key>
					<data>X084MA==</data>
				</dict>
				<dict>
					<key>Comment</key>
					<string>Q81 - O81</string>
					<key>Find</key>
					<data>X1E4MQ==</data>
					<key>Replace</key>
					<data>X084MQ==</data>
				</dict>
				<dict>
					<key>Comment</key>
					<string>Q8A - O8A</string>
					<key>Find</key>
					<data>X1E4QQ==</data>
					<key>Replace</key>
					<data>X084QQ==</data>
				</dict>
				<dict>
					<key>Comment</key>
					<string>Q8C - O8C</string>
					<key>Find</key>
					<data>X1E4Qw==</data>
					<key>Replace</key>
					<data>X084Qw==</data>
				</dict>
				<dict>
					<key>Comment</key>
					<string>QAF -&gt; OAF</string>
					<key>Find</key>
					<data>X1FBRg==</data>
					<key>Replace</key>
					<data>X09BRg==</data>
				</dict>
    */

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
    External (_SB_.PCI0.RP03.PXSX, DeviceObj)
    External (_SB_.PCI0.RP05.PXSX, DeviceObj)
    External (_SB_.PCI0.SATA, DeviceObj)
    External (_SB_.PCI0.SBUS, DeviceObj)
    External (IGDS, IntObj)

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
            
            //define hardware register access for brightness
            // you can see BAR1 value in RW-Everything under Bus00,02 Intel VGA controler PCI
            // Note: Not sure which one is right here... for now, going with BAR1 minus 4
            OperationRegion (BRIT, SystemMemory, Subtract (\_SB.PCI0.IGPU.BAR1, 0x04), 0x000E1184)
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

            Name (XOPT, Zero) // Use XOPT=1 to disable smooth transitions
            Name (XRGL, 0x28) // XRGL/XRGH: defines the valid range
            Name (XRGH, 0x0710)
            Name (KLVX, 0x07100000) // KLVX is initialization value for LEVX
            
            // _BCL: returns list of valid brightness levels
            // first two entries describe ac/battery power levels
            // the range is set to comply with what windows sets - 6% to 90% with 6% icrements, then 100%
            Name (_BCL, Package (0x43)  // _BCL: Brightness Control Levels
            {
                0x0710, 
                0x01DF, 
                Zero, 
                0x06, 
                0x24, 
                0x48, 
                0x6C, 
                0x72, 
                0x90, 
                0xB4, 
                0xD8, 
                0xDE, 
                0xFC, 
                0x0120, 
                0x0144, 
                0x014A, 
                0x0168, 
                0x018C, 
                0x01B0, 
                0x01B6, 
                0x01D4, 
                0x01F8, 
                0x021C, 
                0x0222, 
                0x0240, 
                0x0264, 
                0x0288, 
                0x028E, 
                0x02AC, 
                0x02D0, 
                0x02F4, 
                0x02FA, 
                0x0318, 
                0x032C, 
                0x0360, 
                0x0366, 
                0x0384, 
                0x03A8, 
                0x03CC, 
                0x03D2, 
                0x03F0, 
                0x0414, 
                0x0438, 
                0x043E, 
                0x045C, 
                0x0480, 
                0x04A4, 
                0x04AA, 
                0x04C8, 
                0x04EC, 
                0x0510, 
                0x0516, 
                0x0534, 
                0x0558, 
                0x057C, 
                0x0582, 
                0x05A0, 
                0x05C4, 
                0x05E8, 
                0x05EE, 
                0x060C, 
                0x0630, 
                0x0654, 
                0x066D, 
                0x06A2, 
                0x06D9, 
                0x0710
            })
            
            // _INI deals with differences between native setting and desired
            Method (_INI, 0, NotSerialized)  // _INI: Initialize
            {
                Store (ShiftRight (KLVX, 0x10), Local0)
                Store (ShiftRight (LEVX, 0x10), Local1)
                If (LNotEqual (Local0, Local1))
                {
                    Divide (Multiply (LEVL, Local0), Local1, , Local0)
                    Store (Local0, LEVL)
                    Store (KLVX, LEVX)
                }
            }
            
            // _BCM/_BQC: set/get for brightness level in regular control mode
            Method (_BCM, 1, NotSerialized)  // _BCM: Brightness Control Method
            {
                // initialize for consistent backlight level before/after sleep
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
                If (LEqual (Local0, Ones))
                {
                    Subtract (SizeOf (_BCL), One, Local0)
                }

                If (LNotEqual (LEV2, 0x80000000))
                {
                    Store (0x80000000, LEV2)
                }

                Store (DerefOf (Index (_BCL, Local0)), LEVL)
                
                // write set level into IGPU register so that EC could determine backlight level in BIOS after reboot
                \_SB.PNLF.BSET (\_SB.PNLF.LEVL)
            }

            Method (_BQC, 0, NotSerialized)  // _BQC: Brightness Query Current
            {
                Store (Match (_BCL, MGE, LEVL, MTR, Zero, 0x02), Local0)
                If (LEqual (Local0, Ones))
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
                
                // write set level into IGPU register for later EC query
                \_SB.PNLF.BSET (\_SB.PNLF.LEVL)
            }

            Method (XBQC, 0, NotSerialized)
            {
                Store (LEVL, Local0)
                If (LGreater (Local0, XRGH))
                {
                    Store (XRGH, Local0)
                }

                If (LAnd (Local0, LLess (Local0, XRGL)))
                {
                    Store (XRGL, Local0)
                }

                Return (Local0)
            }

            // sets brightness into CBLV register in order to prevent BIOS from starting with full brightness after reboot
            // EC original queries _Q80 and _Q80 will parse the value from CBLV and perform AND 0xFF on it, 
            // then decrement result by 1 on brightness down event and increment by 1 on brightness up event.
            Method (BSET, 1, NotSerialized)
            {
                Store (Zero, Local0)
                Store (Arg0, Local0)
                If (LAnd (LGreaterEqual (Local0, Zero), LLess (Local0, 0x48)))
                {
                    Store (0x80000006, Local1)
                }

                If (LAnd (LGreaterEqual (Local0, 0x48), LLess (Local0, 0xB4)))
                {
                    Store (0x80000006, Local1)
                }

                If (LAnd (LGreaterEqual (Local0, 0xB4), LLess (Local0, 0x0120)))
                {
                    Store (0x8000000C, Local1)
                }

                If (LAnd (LGreaterEqual (Local0, 0x0120), LLess (Local0, 0x018C)))
                {
                    Store (0x80000012, Local1)
                }

                If (LAnd (LGreaterEqual (Local0, 0x018C), LLess (Local0, 0x01F8)))
                {
                    Store (0x80000018, Local1)
                }

                If (LAnd (LGreaterEqual (Local0, 0x01F8), LLess (Local0, 0x0264)))
                {
                    Store (0x8000001E, Local1)
                }

                If (LAnd (LGreaterEqual (Local0, 0x0264), LLess (Local0, 0x02D0)))
                {
                    Store (0x80000024, Local1)
                }

                If (LAnd (LGreaterEqual (Local0, 0x02D0), LLess (Local0, 0x032C)))
                {
                    Store (0x8000002A, Local1)
                }

                If (LAnd (LGreaterEqual (Local0, 0x032C), LLess (Local0, 0x03A8)))
                {
                    Store (0x80000030, Local1)
                }

                If (LAnd (LGreaterEqual (Local0, 0x03A8), LLess (Local0, 0x0414)))
                {
                    Store (0x80000036, Local1)
                }

                If (LAnd (LGreaterEqual (Local0, 0x0414), LLess (Local0, 0x0480)))
                {
                    Store (0x8000003C, Local1)
                }

                If (LAnd (LGreaterEqual (Local0, 0x0480), LLess (Local0, 0x04EC)))
                {
                    Store (0x80000042, Local1)
                }

                If (LAnd (LGreaterEqual (Local0, 0x04EC), LLess (Local0, 0x0558)))
                {
                    Store (0x80000048, Local1)
                }

                If (LAnd (LGreaterEqual (Local0, 0x0558), LLess (Local0, 0x05C4)))
                {
                    Store (0x8000004E, Local1)
                }

                If (LAnd (LGreaterEqual (Local0, 0x05C4), LLess (Local0, 0x0630)))
                {
                    Store (0x80000054, Local1)
                }

                If (LAnd (LGreaterEqual (Local0, 0x0630), LLess (Local0, 0x06D9)))
                {
                    Store (0x8000005A, Local1)
                }

                If (LOr (LGreaterEqual (Local0, 0x06D9), LEqual (Local0, 0x0710)))
                {
                    Store (0x80000064, Local1)
                }
                // we write to CBLV so original _Q80 and _Q81 could perform AND 0xFF on it and get values from 0 to 64.
                Store (Local1, \_SB.PCI0.IGPU.CBLV) 
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

                Return (Package (0x02)
                {
                    "RM,oem-id", 
                    "DELL"
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
            // brightness up event
            Method (RKA1, 1, NotSerialized)
            {
                If (LNot(Arg0))
                {
                    \_SB.PCI0.LPCB.EC0._O80 ()
                }
            }
            // brightness down event
            Method (RKA2, 1, NotSerialized)
            {
                If (LNot(Arg0))
                {
                    \_SB.PCI0.LPCB.EC0._O81 ()
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
                \_SB.PCI0.LPCB.EC0._O80 ()
            }
            // this will be called when Fn+F4 is pressed
            Method (_Q81, 0, NotSerialized)  // _Qxx: EC Query
            {
                Notify (PS2K, 0x0205)
                Notify (PS2K, 0x0285)
                \_SB.PCI0.LPCB.EC0._O81 ()
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
        Scope (\_SB.PCI0.RP03.PXSX)
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
        Scope (\_SB.PCI0.RP05.PXSX)
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

            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                Store (Package (0x0E)
                    {
                        "device-id", 
                        Buffer (0x04)
                        {
                             0x26, 0x01, 0x00, 0x00
                        }, 

                        "AAPL,NumFramebuffers", 
                        Buffer (0x04)
                        {
                             0x03, 0x00, 0x00, 0x00
                        }, 

                        "hda-gfx", 
                        Buffer (0x0A)
                        {
                            "onboard-1"
                        }, 

                        "revision-id", 
                        Buffer (0x04)
                        {
                             0x09, 0x00, 0x00, 0x00
                        }, 

                        "subsystem-id", 
                        Buffer (0x04)
                        {
                             0xDB, 0x00, 0x00, 0x00
                        }, 

                        "subsystem-vendor-id", 
                        Buffer (0x04)
                        {
                             0x6B, 0x10, 0x00, 0x00
                        }, 

                        "vendor-id", 
                        Buffer (0x04)
                        {
                             0x86, 0x80, 0x00, 0x00
                        }
                    }, Local0)
                DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                Return (Local0)
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
                             0x1C, 0x00, 0x00, 0x00
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

