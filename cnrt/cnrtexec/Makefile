
#CFLAGS=-I /usr/local/neuware/include/ -g  -std=c++11
CFLAGS=-I $(NEUWARE_HOME)/include/ -g  -std=c++11
CXXFLAGS=$(CFLAGS)

#LDFALGS=-L /usr/local/neuware/lib64  -Wl,-rpath=/usr/local/neuware/lib64
LDFALGS=-L $(NEUWARE_HOME)/lib64  -Wl,-rpath=$(NEUWARE_HOME)/lib64

#CXX=g++
CXX=aarch64-linux-gnu-g++

CNRT_DEMO_SRC=$(wildcard *.cpp)
CNRT_DEMO_OBJ=$(CNRT_DEMO_SRC:%.cpp=%.o)

CNRT_DEMO=cnrtexec

all:$(CNRT_DEMO)

$(CNRT_DEMO):$(CNRT_DEMO_OBJ)
	$(CXX) -o $@ $(CNRT_DEMO_OBJ) $(LDFALGS) -lcnrt -lpthread
	
clean:
	rm  -f $(CNRT_DEMO) $(CNRT_DEMO_OBJ)

