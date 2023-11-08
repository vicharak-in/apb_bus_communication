# apb_bus_communication
APB Write Transfer Implementation with Dual UART Transmitters and FIFO Buffer
Introduction
- The APB Write Transfer Implementation focuses on efficiently transferring data using the Advanced Peripheral Bus protocol. It utilizes two UART transmitters as slave devices, along with a FIFO buffer, master controller, slave controller, and peripheral controller.

Implementation Overview
- Data received by the UART receiver is stored in the FIFO buffer.
- Master Controller --> This module controls the reading of the data from the fifo and sends psel- 1 byte, pwrite- 1 byte, paddr- 4 bytes and pwdata- 4 bytes to the master and so it controls the input data that goes to the master.
- Master --> This is the master design, the psel, pwrite, paddr and pwdata sent by the master controller goes to the ext_psel, ext_write, ext_addr, ext_wdata. Master sends these signals to the slave andin turn get a ready as a response from the slave whenever the slave is ready.
- Slave/Controller --> This is slave-cum-controller which gives out the ready to master when it receives valid from the peripheral controller after sending the 32 bits wide pwdata and 32 bits wide paddr to fifo.
Slave Peripheral Controller --> This is the slave peripheral controller which controls the reading of the data from the fifo and converts the 32 bits wide paddr and pwdata into 8 bits. And this is then sent to the transmitter.

- the top design and the flow of the data is as follows -
              ***** UART RX - FIFO - MASTER CONTROLLER - MASTER (Broadcasts outputs to both the slaves)- 
  SLAVE 1 --->      SLAVE/CONTROLLER - FIFO - SLAVE PERIPEHRAL CONTROLLER- UART TX
              Based on the select line either slave 1 or slave 2 is selected
  SLAVE 2 -->       SLAVE/CONTROLLER - FIFO - SLAVE PERIPEHRAL CONTROLLER- UART TX *****
This design works only for the write transfer     






APB Protocol- LEARNINGS

1. What are different types of bus protocols and why should we have them? Difference between throughput, bandwidth and latency?
-->  APB, AHB and AXI are the different buses which are part of AMBA family protocols. The Advanced Microcontroller Bus Architecture, or AMBA, is an open-standard, on-chip interconnect specification for the connection and management of functional blocks in system-on-a-chip (SoC) designs.
- AMBA provides several benefits:
- Efficient IP reuse: IP reuse is an essential component in reducing SoC development costs and timescales. AMBA specifications provide the interface standard that enables IP reuse. Therefore, thousands of SoCs, and IP products, are using AMBA interfaces.
- Flexibility: AMBA offers the flexibility to work with a range of SoCs. IP reuse requires a common standard while supporting a wide variety of SoCs with different power, performance, and area requirements. Arm offers a range of interface specifications that are optimized for these different requirements.
- Compatibility: A standard interface specification, like AMBA, allows compatibility between IP components from different design teams or vendors.
- Support: AMBA is well supported. It is widely implemented and supported throughout the semiconductor industry, including support from third-party IP products and tools. 
  Bus interface standards like AMBA, are differentiated through the performance that they enable. 

The three main characteristics of bus interface performance are:
- Bandwidth is the maximum theoretical data transfer rate of a network or data connection. Latency is the time it takes for data to get from one designated point to another. Throughput is the amount of data successfully transferred between two points over a given time period.
- Bandwidth and latency work together, but they measure two different things. High bandwidth + low latency = greater throughput.
- Higher bandwidth typically enables higher throughput. However, bandwidth is only a potential rate, and the actual throughput could be lower due to other factors. Higher network latency can reduce throughput because it takes longer for data packets to travel across the network. 
- A good network will have low latency, high throughput and high bandwidth 


2. What is APB? Advantages and disadvantages of APB bus? 

--> The Advanced Peripheral Bus (APB) is used for connecting low bandwidth peripherals. 
It is a simple non-pipelined protocol that can be used to communicate(read or write) from a bridge/master to a number of slaves through the shared bus. The reads and writes shares the same set of signals and no burst data 
transfers are supported.

Advantages of APB Bus:
--Simplicity: The APB protocol is relatively simple and easy to understand compared to more complex bus protocols like AHB (Advanced High-performance Bus) and AXI (Advanced eXtensible Interface). This simplicity can lead to faster design and verification.
--Low Power: APB is designed to be a low-power protocol, making it suitable for battery-operated devices and low-power applications. It minimizes power consumption by avoiding excessive toggling of signals when idle.
--Area Efficiency: APB typically requires less area on the chip compared to more complex bus protocols, which can help reduce the size and cost of the silicon.
--Peripheral Integration: It is well-suited for integrating simple peripherals, such as UARTs, timers, and GPIO controllers, into an SoC.
--Legacy Compatibility: Many existing designs and IP blocks are based on the APB protocol, making it valuable for designs that need to interoperate with legacy components.

Disadvantages of APB Bus:
--Limited Bandwidth: APB has a lower bandwidth compared to more advanced bus protocols like AHB and AXI. This limitation can be a bottleneck for high-performance applications with demanding data transfer requirements.

--Not Suitable for High-Performance Cores: APB is not suitable for connecting high-performance CPU cores and memory subsystems due to its limited bandwidth and simplicity. For such applications, more advanced bus protocols like AHB or AXI are preferred.

--Limited Features: APB lacks some advanced features found in more complex bus protocols. For example, it doesn't support out-of-order transactions or complex burst transfers.

--Complex Interconnect: In larger SoCs with multiple peripherals, connecting numerous APB buses to a shared interconnect can become complex and may require additional arbitration logic.

--Limited Scalability: While APB is suitable for small to medium-sized SoCs, it may not scale well for extremely complex designs that require high levels of performance and flexibility.

In summary, the choice of using the APB bus or any other bus protocol depends on the specific requirements of the SoC design. APB is advantageous for simpler, low-power, and area-efficient designs with peripherals that do not require high bandwidth. However, for more complex and high-performance applications, other bus protocols like AHB or AXI may be more appropriate despite their increased complexity.
 

3. Why bus like APB, when we have high speed buses like AHB or AXI?
--> APB is a system bus for low bandwidth peripherals unlike AHB/AXI is used for High-Frequency Design

4. What is the operating frequency of APB?
--> 20-50mhz

5. What are the various interfacing signals in AMBA APB protocol specification v2.0 and their importance?
--> PCLK -  Clock. The rising edge of PCLK times all transfers on the APB.
    PRESETn - Reset. The APB reset signal is active LOW. This signal is normally connected directly to the system bus reset signal.
    PADDR - Address. This is the APB address bus. It can be up to 32 bits wide and is driven by the peripheral bus bridge unit
    PPROT - Protection type. This signal indicates the normal, privileged, or secure protection level of the transaction and whether the transaction is a data access or an instruction access.
   PSELx - Select. The APB bridge unit generates this signal to each peripheral bus slave. It indicates that the slave device is selected and that a data transfer is required. There is a PSELx signal for each slave.
   PENABLE - Enable. This signal indicates the second and subsequent cycles of an APB 
transfer
   PWRITE - Direction. This signal indicates an APB write access when HIGH and an APB 
read access when LOW
   PWDATA - Write data. This bus is driven by the peripheral bus bridge unit during write 
cycles when PWRITE is HIGH. This bus can be up to 32 bits wide.
   PSTRB - Write strobes. This signal indicates which byte lanes to update during a write 
transfer. There is one write strobe for each eight bits of the write data bus. Therefore, PSTRB[n] corresponds to PWDATA[(8n + 7):(8n)]. Write strobes must not be active during a read transfer.
   PREADY - Ready. The slave uses this signal to extend an APB transfer.
   PRDATA - Read Data. The selected slave drives this bus during read cycles when PWRITE is LOW. This bus can be up to 32-bits wide.
   PSLVERR - This signal indicates a transfer failure. APB peripherals are not required to support the PSLVERR pin. This is true for both existing and new APB peripheral designs. Where a peripheral does not include this pin then the appropriate input to the APB bridge is tied LOW.
 

6. What is the relevance of protection in APB protocol? How is the secure transfer ensured?
-->  This signal indicates the normal, privileged, or secure protection level of the transaction and whether the transaction is a data access or an instruction access.

7. What is the data and the address width of the bus?
--> 32 bits 

8. Why do we have PSTRB signal?
--> A write strobe signal to enable sparse data transfer on the write data bus. This version of the specification is referred to as APB4.

9. Should the PSEL and PENABLE remain high if the same peripheral is selected again for the transaction according to the protocol?
-->  The enable signal PENABLE, is deasserted at the end of the transfer. The select signal PSEL, is also deasserted unless the transfer is to be followed immediately by another transfer to the same peripheral 


10. When we say address in PADDR, what exactly does it mean? 
-->  When we say "getting the address of that peripheral," it means determining the specific memory address or range of addresses associated with a particular peripheral device.

11. What is the significance of PENABLE signal when we have PREADY, PSEL, PWRITE signals?
--> The penable is required because,
Psel is used to select a slave, pwrite is to configure it as a read/ write transfer, pready is a confirmation from the slaves end that it is ready for the transaction, so now that we have understood what the other signals do but have we initiated the tranfser yet? No, so this is what Penable does. 


12. What is read and write transfers with wait states and with no wait states?
--> With wait is,
if the slave is busy with some other opeartion then it would respond back with the ready after it gets free so until then the master has to wait which is called as read/write transfer with wait state and if free it respinds back with the ready immediately where, no wait states are required.
 
13. What are the states in which APB operates?
--> IDLE, SETUP and ACCESS

14. Is it possible for data transfers to occur on both buses at the same time?
-->  The APB protocol has two independent data buses, one for read data and one for write data. The buses can be up to 32 bits wide. Because the buses do not have their own individual handshake signals, so it is not possible for data transfers to occur on both buses at the same time. 
