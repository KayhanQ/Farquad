//
//  CPP.cpp
//  SO-32541268
//
//  Copyright (c) 2015 Xavier Schott
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

// Definition: CPP.cpp
#include "CPP.hpp"
#include "C.h"
#include <iostream>

#include <fcntl.h>
#include <stdio.h>
#include <sys/stat.h>
#include <unistd.h>

#define MAX_BUF 1024

using namespace std;

void CPP::helloWorld_cpp() {
    cout << "Hello World in C++" << endl;
}

void CPP::hello_cpp(const std::string& name) {
    hello_c(name.c_str());
    cout << "Hello " << name << " in C++" << endl;
}


int CPP::hasCollided() {
    return 1;
}

std::string CPP::getQuadBox() {
    int fd;
    const char *myfifo = "/tmp/quadData";
    char buf[MAX_BUF];
    
    /* open, read, and display the message from the FIFO */
    fd = open(myfifo, O_RDONLY);
    if (fd != -1) {
        read(fd, buf, MAX_BUF);
        close(fd);
        return buf;
    }
    
    return "";
}
