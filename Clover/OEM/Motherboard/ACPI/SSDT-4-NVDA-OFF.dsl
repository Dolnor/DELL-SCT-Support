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
DefinitionBlock ("SSDT-4.aml", "SSDT", 2, "DELL ", "SsdtOPTS", 0x00001000)
{

    External (P8XH, MethodObj)
    External (_SB_.PHSR, MethodObj)
    External (_SB_.PCI0, DeviceObj)
    External (_SB_.PCI0.PEG0, DeviceObj)
    External (_SB_.PCI0.PEG0.PEGP, DeviceObj)
    External (_SB_.PCI0.PEG0.PEGP._PS3, MethodObj)
    External (_SB_.PCI0.PEG0.PEGP._DSM, MethodObj)
    External (_SB_.PCI0.PEG0.PEGP.LCRB, IntObj)
    External (_SB_.PCI0.PEG0.PEGP.DQDA, IntObj)
    External (_SB_.PCI0.PEG0.PEGP.DGPW, IntObj)
    External (_SB_.PCI0.PEG0.PEGP.DGRS, IntObj)
    External (_SB_.PCI0.PEG0.PEGP.DGOS, IntObj)
    External (_SB_.PCI0.PEG0.PEGP.OMPR, IntObj)
    External (_SB_.PCI0.PEG0.PEGP._PSC, IntObj)

    Scope (\_SB.PCI0)
    {        
        // Disable NVIDIA Optimus Switchable Graphics
        Scope (\_SB.PCI0.PEG0)
        {
                        
            Method (_INI, 0, NotSerialized)  // _INI: Initialize
            {
                \_SB.PCI0.PEG0.PEGP._DSM (Buffer (0x10)
                    {
                        /* 0000 */   0xF8, 0xD8, 0x86, 0xA4, 0xDA, 0x0B, 0x1B, 0x47,
                        /* 0008 */   0xA7, 0x2B, 0x60, 0x42, 0xA6, 0xB5, 0xBE, 0xE0
                    }, 0x0100, 0x1A, Buffer (0x04)
                    {
                         0x01, 0x00, 0x00, 0x03
                    })
                If (One)
                {
                    \_SB.PCI0.PEG0.PEGP.NOFF ()
                }
            }
        }
                      
        Scope (\_SB.PCI0.PEG0.PEGP)
        {
            // Disable NVDA regs to allow proper restart
            Method (NOFF, 0, NotSerialized)
            {
                P8XH (Zero, 0xF2)
                P8XH (Zero, 0xF3)
                PHSR (0xB4)
                Store (Zero, LCRB)
                Store (Zero, DQDA)
                Store (Zero, DGPW)
                Store (Zero, DGRS)
                Sleep (0x64)
                Store (Zero, DGOS)
                Store (0x02, OMPR)
                Store (Zero, _PSC)
            }
        }
    }
}

