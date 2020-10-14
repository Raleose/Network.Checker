using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Net;
using System.Net.NetworkInformation;
using System.Text;

namespace NetworkChecker
{
    class Program
    {
        static void Main(string[] args)
        {
            var adresses = new List<byte>();
            for (int i = 0; i < 256; i++)
            {
                adresses.Add((byte)i);
            }
            var networkIps = new List<IPAddress>();
            adresses.AsParallel().ForAll(b =>
            {
                var ip = $"192.168.0.{b}";
                if (PingForAddress(ip))
                {
                    networkIps.Add(IPAddress.Parse(ip));

                }
            });
            Console.WriteLine($"Найдено устройств: {networkIps.Count()}");
            Console.WriteLine(string.Join(", ", networkIps.Select(ip => ip.ToString())));
            
            Console.ReadLine();
        }

        static bool PingForAddress(string ip)
        {
            var pingSender = new Ping();
            var options = new PingOptions
            {
                DontFragment = true
            };
            int timeout = 120;
            var buffer = Encoding.UTF8.GetBytes("1234");
            var reply = pingSender.Send(ip, timeout, buffer, options);
            if (reply.Status == IPStatus.Success)
            {
                Console.WriteLine();
                Console.WriteLine("Address: {0}", reply.Address.ToString());
                Console.WriteLine("RoundTrip time: {0}", reply.RoundtripTime);
                Console.WriteLine("Time to live: {0}", reply.Options.Ttl);
                Console.WriteLine("Don't fragment: {0}", reply.Options.DontFragment);
                Console.WriteLine("Buffer size: {0}", reply.Buffer.Length);
                Console.WriteLine();
                return true;
            }
            return false;
        }
    }
}
