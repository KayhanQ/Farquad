//
//  CPP-Wrapper.mm
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

// Definition: CPP-Wrapper.mm
#import "CPP-Wrapper.h"
#include "CPP.hpp"

@implementation CPP_Wrapper

- (void)helloWorld_cpp_wrapped {
    CPP cpp;
    cpp.helloWorld_cpp();
}

- (void)hello_cpp_wrapped:(NSString *)name {
    CPP cpp;
    cpp.hello_cpp([name cStringUsingEncoding:NSUTF8StringEncoding]);
}

- (int)hasCollided_wrapped {
    CPP cpp;
    return cpp.hasCollided();
}

- (NSString*)getQuadBox_wrapped {
    CPP cpp;
    std::string string = cpp.getQuadBox();
    
    NSString* result = [NSString stringWithUTF8String: string.c_str()];
    return result;
}


@end
