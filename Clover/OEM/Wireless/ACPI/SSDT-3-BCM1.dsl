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
DefinitionBlock ("SSDT-3.aml", "SSDT", 2, "DELL ", "SsdtArpt", 0x00001000)
{
    
    External (DTGP, MethodObj)
    External (_SB_.PCI0, DeviceObj)
    External (_SB_.PCI0.RP01.PXSX, DeviceObj)

    Scope (\_SB.PCI0)
    {
        // Custom property injection for AzureWave NB-290 card
        Scope (\_SB.PCI0.RP01.PXSX)
        {
            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                Store (Package (0x14)
                    {
                        "built-in", 
                        Buffer (One)
                        {
                             0x00
                        }, 

                        "model", 
                        Buffer (0x10)
                        {
                            "AirPort Extreme"
                        }, 

                        "subsystem-id", 
                        Buffer (0x04)
                        {
                             0x8F, 0x00, 0x00, 0x00
                        }, 

                        "subsystem-vendor-id", 
                        Buffer (0x04)
                        {
                             0x6B, 0x10, 0x00, 0x00
                        }, 

                        "device_type", 
                        Buffer (0x08)
                        {
                            "AirPort"
                        }, 

                        "AAPL,slot-name", 
                        Buffer (0x08)
                        {
                            "AirPort"
                        }, 

                        "device-id", 
                        Buffer (0x04)
                        {
                             0xA0, 0x43, 0x00, 0x00
                        }, 

                        "vendor-id", 
                        Buffer (0x04)
                        {
                             0xE4, 0x14, 0x00, 0x00
                        }, 

                        "name", 
                        Buffer (0x0D)
                        {
                            "pci14e4,43a0"
                        }, 

                        "compatible", 
                        Buffer (0x0D)
                        {
                            "pci14e4,43a0"
                        }
                    }, Local0)
                DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                Return (Local0)
            }
        }
    }
}

